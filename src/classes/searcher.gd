@tool
extends Resource
class_name Searcher
## 搜索器类。
##
## [Searcher] 用于搜索实体，支持根据位置、半径、条件等进行搜索。


## 排序模式枚举。
enum SortMode {
	## 排序模式: 路程。
	PROGRESS,
	## 排序模式: 距离。
	DISTANCE,
	## 排序模式: 血量。
	HEALTH,
	## 排序模式: 近战伤害。
	MELEE_DAMAGE,
	## 排序模式: 远程伤害。
	RANGED_DAMAGE,
	## 排序模式: 实体 ID。
	ID,
	## 排序模式: 赏金。
	GOLD,
	## 排序模式: 随机。
	RANDOM,
}


## 搜索标识枚举。
enum SearchFlag {
	## 搜索标识: 无。
	NONE = 0,
	## 搜索标识: 跳过即将死亡的目标。
	SKIP_DOOMED = 1,
	## 搜索标识: 可搜索已死亡的目标。
	SKIP_DEAD = 1 << 1,
}


## 搜索中心偏移量。
@export var center_offsets: OffsetGroup = null:
	set(v): 
		Utils.rebind_changed(center_offsets, v, emit_changed)
		center_offsets = v
		emit_changed()
## 搜索最小半径。
@export var min_radius: float = 0.0:
	set(v): 
		min_radius = v
		emit_changed()
## 搜索最大半径。
@export var max_radius: float = 0.0:
	set(v): 
		max_radius = v
		emit_changed()
## 最大搜索目标数量，-1 表示不限制。
@export var max_search: int = Constants.UNSET

@export_group("Search Policy")
## 是否启用排除自身实体。
@export var exclude_self_entity_enabled: bool = true
## 搜索的阵容。
@export var target_faction: InteractPolicyComponent.Faction = InteractPolicyComponent.Faction.ENEMY
## 搜索的实体类型。
@export var target_entity_types: int = InteractPolicyComponent.EntityType.UNIT
## 搜索标识。
@export var search_flag: int = SearchFlag.SKIP_DOOMED | SearchFlag.SKIP_DEAD
## 禁止搜索的实体标识。
@export var entity_flag_bans: int = 0
## 禁止搜索的实体场景路径。
@export_file("*.tscn") var scene_path_bans: PackedStringArray
## 允许搜索的实体场景路径。
@export_file("*.tscn") var scene_path_allows: PackedStringArray

@export_group("Sort Policy")
## 排序模式。
@export var sort_mode: SortMode = SortMode.PROGRESS
## 实体交互策略标识排序优先级列表。
@export var interact_policy_flag_sort_prioritys: Array[InteractPolicyComponent.EntityFlag] = []
## 是否启用升序排序。
@export var sort_ascending_enabled: bool = false

var _init_connect_property_signals: Dictionary[String, Callable] = {
	"center_offsets": emit_changed,
}


func _init() -> void:
	resource_local_to_scene = true
	Utils.connect_property_signals(self, _init_connect_property_signals)


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"entity_flag_bans":
			property.hint_string = "mask_check(%s)" % InteractPolicyComponent.EntityFlag
		"search_flag":
			property.hint_string = "mask_check(%s)" % SearchFlag
		"target_entity_types":
			property.hint_string = "mask_check(%s)" % InteractPolicyComponent.EntityType


## 搜索单个目标。
func search_target(center: Vector2, search_entity: Entity = null, filter := Callable()) -> Entity:
	var targets: Array[Entity] = search_targets(center, search_entity, filter)
	if targets:
		return targets[0]

	return null


## 绘制搜索范围。
func draw_search_range(drawer: CanvasItem, center: Vector2) -> void:
	if center_offsets:
		Utils.draw_range_ellipse(drawer, center + center_offsets.right, min_radius, max_radius)

		center_offsets.draw_offset_group(drawer)
	else:
		Utils.draw_range_ellipse(drawer, center, min_radius, max_radius)


## 搜索目标。
func search_targets(center: Vector2, entity: Entity = null, filter := Callable()) -> Array[Entity]:
	if entity and center_offsets:
		var center_offset: Vector2 = center_offsets.get_offset_toward_point(entity.global_position, entity.facing_global_position)
		center += center_offset

	var faction: InteractPolicyComponent.Faction = target_faction
	var interact_policy_c: InteractPolicyComponent = entity.get_node_or_null(Constants.INTERACT_POLICY_COMPONENT_NODE_PATH)
	if interact_policy_c:
		if entity and interact_policy_c.config.faction & InteractPolicyComponent.Faction.ENEMY:
			match target_faction:
				InteractPolicyComponent.Faction.ENEMY: faction = InteractPolicyComponent.Faction.FRIENDLY
				InteractPolicyComponent.Faction.FRIENDLY: faction = InteractPolicyComponent.Faction.ENEMY
	
	filter = _get_packed_filter(entity, interact_policy_c, filter)
	var targets: Array[Entity] = (
		EntitySpatialHashManager.search_entities_in_ellipse_filtered(
			center, 
			min_radius, 
			max_radius, 
			faction,
			target_entity_types,
			filter,
		) 
		if filter.is_valid() else 
		EntitySpatialHashManager.search_entities_in_ellipse(
			center, 
			min_radius, 
			max_radius, 
			faction,
			target_entity_types,
		)
	)
	if interact_policy_flag_sort_prioritys.size() == 0:
		_sort_targets(targets, center)
	else:
		var buckets: Dictionary[InteractPolicyComponent.EntityFlag, Array] = {}
		var other_entities: Array[Entity] = []
		for target: Entity in targets:
			var target_interact_policy_c: InteractPolicyComponent = target.get_node_or_null(Constants.INTERACT_POLICY_COMPONENT_NODE_PATH)
			if not target_interact_policy_c:
				other_entities.append(target)
				continue

			var is_found: bool = false
			var has_flags: int = target_interact_policy_c.config.entity_flags
			for flag: InteractPolicyComponent.EntityFlag in interact_policy_flag_sort_prioritys:
				if not has_flags & flag:
					continue
				
				if not buckets.has(flag):
					var bucket: Array[Entity] = []
					buckets[flag] = bucket
					
				buckets[flag].append(target)
				is_found = true
				break

			if is_found:
				continue
			
			other_entities.append(target)

		var new_targets: Array[Entity] = []
		for flag: InteractPolicyComponent.EntityFlag in interact_policy_flag_sort_prioritys:
			if not buckets.has(flag):
				continue
				
			var bucket: Array[Entity] = buckets[flag]
			_sort_targets(bucket, center)
			new_targets.append_array(bucket)

		_sort_targets(other_entities, center)
		new_targets.append_array(other_entities)
		targets = new_targets

	if max_search != Constants.UNSET and targets.size() > max_search:
		targets.resize(max_search)

	return targets


#region 过滤器
## 获取打包后的过滤器。
func _get_packed_filter(entity: Entity, interact_policy_c: InteractPolicyComponent, filter: Callable) -> Callable:
	var extra_filters: Array[Callable] = []
	if search_flag & SearchFlag.SKIP_DOOMED: extra_filters.append(_skip_doomed_filter)
	if search_flag & SearchFlag.SKIP_DEAD: extra_filters.append(_skip_dead_filter)
			
	if extra_filters.size() > 0:
		var extra_filter: Callable = func(target: Entity) -> bool:
			if exclude_self_entity_enabled and target == entity:
				return false
				
			var target_interact_policy_c: InteractPolicyComponent = target.get_node_or_null(Constants.INTERACT_POLICY_COMPONENT_NODE_PATH)
			if interact_policy_c and target_interact_policy_c:
				if interact_policy_c.is_banned_either(target_interact_policy_c, entity.scene_file_uid, target.scene_file_uid):
					return false

			for f: Callable in extra_filters:
				if f.call(target):
					continue
				return false
			return true
		if filter.is_valid():
			filter = func(target: Entity) -> bool: 
				return filter.call(target) and extra_filter.call(target)
		else:
			filter = extra_filter

	return filter


## 跳过注定死亡目标过滤器。
func _skip_doomed_filter(target: Entity) -> bool:
	var health_c: HealthComponent = target.get_node_or_null(Constants.HEALTH_COMPONENT_NODE_PATH)
	if not health_c:
		return false

	return health_c.total_pending_damage_value < health_c.hp


## 跳过已死亡目标过滤器。
func _skip_dead_filter(target: Entity) -> bool:
	return not target.state & Entity.State.DEAD
#endregion


#region 排序
## 排序实体数组。
func _sort_targets(targets: Array[Entity], search_global_position: Vector2) -> void:
	var sort_function: Callable = Callable()
	match sort_mode:
		SortMode.PROGRESS: sort_function = _sort_by_progress
		SortMode.HEALTH: sort_function = _sort_by_health
		SortMode.GOLD: sort_function = _sort_by_gold
		SortMode.DISTANCE: sort_function = _sort_by_distance.bind(search_global_position)
		SortMode.MELEE_DAMAGE: sort_function = _sort_by_melee_damage
		SortMode.RANGED_DAMAGE: sort_function = _sort_by_ranged_damage
		SortMode.ID: sort_function = _sort_by_id
		SortMode.RANDOM:
			targets.shuffle()
			return

	targets.sort_custom(sort_function)


## 排序模式: 路程。
func _sort_by_progress(a: Entity, b: Entity) -> bool:
	var progress_a: float = INF if sort_ascending_enabled else -INF
	var progress_b: float = INF if sort_ascending_enabled else -INF

	var nav_path_c_a: NavPathComponent = a.get_node_or_null(Constants.NAV_PATH_COMPONENT_NODE_PATH)
	if nav_path_c_a:
		progress_a = nav_path_c_a.progress

	var nav_path_c_b: NavPathComponent = b.get_node_or_null(Constants.NAV_PATH_COMPONENT_NODE_PATH)
	if nav_path_c_b:
		progress_b = nav_path_c_b.progress

	return progress_a < progress_b if sort_ascending_enabled else progress_a > progress_b


## 排序模式: 血量。
func _sort_by_health(a: Entity, b: Entity) -> bool:
	var hp_a: float = INF if sort_ascending_enabled else -INF
	var hp_b: float = INF if sort_ascending_enabled else -INF

	var health_c_a: HealthComponent = a.get_node_or_null(Constants.HEALTH_COMPONENT_NODE_PATH)
	if health_c_a:
		hp_a = health_c_a.hp
	var health_c_b: HealthComponent = b.get_node_or_null(Constants.HEALTH_COMPONENT_NODE_PATH)
	if health_c_b:
		hp_b = health_c_b.hp

	return hp_a < hp_b if sort_ascending_enabled else hp_a > hp_b


## 排序模式: 赏金。
func _sort_by_gold(a: Entity, b: Entity) -> bool:
	var gold_a: float = INF
	var gold_b: float = INF

	var health_c_a: HealthComponent = a.get_node_or_null(Constants.HEALTH_COMPONENT_NODE_PATH)
	if health_c_a:
		gold_a = health_c_a.config.death_gold
	var health_c_b: HealthComponent = b.get_node_or_null(Constants.HEALTH_COMPONENT_NODE_PATH)
	if health_c_b:
		gold_b = health_c_b.config.death_gold

	return gold_a < gold_b if sort_ascending_enabled else gold_a > gold_b


## 排序模式: 距离。
func _sort_by_distance(a: Entity, b: Entity, search_global_position: Vector2) -> bool:
	var distance_a: float = a.global_position.distance_squared_to(search_global_position)
	var distance_b: float = b.global_position.distance_squared_to(search_global_position)

	return distance_a < distance_b if sort_ascending_enabled else distance_a > distance_b


## 排序模式: 近战伤害。
func _sort_by_melee_damage(a: Entity, b: Entity) -> bool:
	var melee_damage_a: float = INF if sort_ascending_enabled else -INF
	var melee_damage_b: float = INF if sort_ascending_enabled else -INF
	
	var a_melee_c: MeleeComponent = a.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
	if a_melee_c:
		var first_melee_skill := a_melee_c.get_child(0) as MeleeSkill
		if first_melee_skill:
			var damage_influence := first_melee_skill.config.influence as DamageInfluence
			if damage_influence:
				melee_damage_a = (damage_influence.min_value + damage_influence.damage_max) / 2.0
	var b_melee_c: MeleeComponent = b.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
	if b_melee_c:
		var first_melee_skill := b_melee_c.get_child(0) as MeleeSkill
		if first_melee_skill:
			var damage_influence := first_melee_skill.config.influence as DamageInfluence
			if damage_influence:
				melee_damage_b = (damage_influence.min_value + damage_influence.damage_max) / 2.0

	return melee_damage_a < melee_damage_b if sort_ascending_enabled else melee_damage_a > melee_damage_b


## 排序模式: 远程伤害。
func _sort_by_ranged_damage(a: Entity, b: Entity) -> bool:
	var ranged_damage_a: float = INF if sort_ascending_enabled else -INF
	var ranged_damage_b: float = INF if sort_ascending_enabled else -INF
		
	var a_skill_c: SkillComponent = a.get_node_or_null(Constants.SKILL_COMPONENT_NODE_PATH)
	if a_skill_c:
		var first_ranged_skill := a_skill_c.get_child(0) as RangedSkill
		if first_ranged_skill:
			var bullet_template: NodeConfigTemplateNode = NodeConfigManager.get_node_config_template_by_entity_uid(first_ranged_skill.config.bullet_scene)
			var bullet_c_config: BulletComponentNodeConfig = bullet_template.get_node_config(Constants.BULLET_COMPONENT_NODE_PATH)
			var damage_influence := bullet_c_config.influence as DamageInfluence
			if damage_influence:
				ranged_damage_a = (damage_influence.min_value + damage_influence.damage_max) / 2.0
	var b_skill_c: SkillComponent = b.get_node_or_null(Constants.SKILL_COMPONENT_NODE_PATH)
	if b_skill_c:
		var first_ranged_skill := b_skill_c.get_child(0) as RangedSkill
		if first_ranged_skill:
			var bullet_template: NodeConfigTemplateNode = NodeConfigManager.get_node_config_template_by_entity_uid(first_ranged_skill.config.bullet_scene)
			var bullet_c_config: BulletComponentNodeConfig = bullet_template.get_node_config(Constants.BULLET_COMPONENT_NODE_PATH)
			var damage_influence := bullet_c_config.influence as DamageInfluence
			if damage_influence:
				ranged_damage_b = (damage_influence.min_value + damage_influence.damage_max) / 2.0

	return ranged_damage_a < ranged_damage_b if sort_ascending_enabled else ranged_damage_a > ranged_damage_b


## 排序模式: 实体 ID。
func _sort_by_id(a: Entity, b: Entity) -> bool:
	var id_a: int = a.id
	var id_b: int = b.id
	
	return id_a < id_b if sort_ascending_enabled else id_a > id_b
#endregion
