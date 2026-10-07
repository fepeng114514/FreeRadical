@tool
extends Resource
class_name Searcher
## 搜索器类。
##
## Searcher 用于根据位置、半径等条件搜索实体。


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


## 搜索组枚举。
enum SearchedGroup {
	## 搜索组：实体。
	ENTITIES,
	## 搜索组: 敌人。
	ENEMIES,
	## 搜索组: 友军。
	FRIENDLIES,
	## 搜索组: 单位。
	UNITS,
	## 搜索组: 防御塔。
	TOWERS,
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
## 搜索组。
@export var searched_group: SearchedGroup = SearchedGroup.ENEMIES
## 搜索标识。
@export var search_flag: int = SearchFlag.SKIP_DOOMED | SearchFlag.SKIP_DEAD
## 交互策略。
@export var interact_policy: InteractPolicy = null

@export_group("Sort Policy")
## 排序模式。
@export var sort_mode: SortMode = SortMode.PROGRESS
## 实体交互策略标识排序优先级列表。
@export var interact_policy_flag_sort_priority: Array[InteractPolicy.Flag] = []
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
		"search_flag":
			property.hint_string = "mask_check(%s)" % SearchFlag


## 搜索目标。
func search_targets(center: Vector2, search_entity: Entity = null, filter := Callable()) -> Array[Entity]:
	if search_entity and center_offsets:
		var center_offset: Vector2 = center_offsets.get_offset_toward_point(search_entity.global_position, search_entity.facing_global_position)
		center += center_offset

	var is_enemy: bool = search_entity and search_entity.config.interact_policy and search_entity.config.interact_policy.flags & InteractPolicy.Flag.ENEMY
	var group_name: StringName = &""
	match searched_group:
		SearchedGroup.ENEMIES: group_name = Constants.GROUP_FRIENDLIES if is_enemy else Constants.GROUP_ENEMIES	
		SearchedGroup.FRIENDLIES: group_name = Constants.GROUP_ENEMIES if is_enemy else Constants.GROUP_FRIENDLIES
		SearchedGroup.UNITS: group_name = Constants.GROUP_UNITS
		SearchedGroup.TOWERS: group_name = Constants.GROUP_TOWERS

	var extra_filters: Array[Callable] = []
	if search_flag & SearchFlag.SKIP_DOOMED: extra_filters.append(_skip_doomed_filter)
	if search_flag & SearchFlag.SKIP_DEAD: extra_filters.append(_skip_dead_filter)
			
	if extra_filters.size() > 0:
		var packed_filter: Callable = _packed_filters.bind(extra_filters)
		if filter.is_valid():
			filter = func(entity: Entity) -> bool: 
				return filter.call(entity) and packed_filter.call(entity)
		else:
			filter = packed_filter
			
	var targets: Array[Entity] = (
		EntityManager.search_entities_in_ellipse_filtered(
			center, 
			min_radius, 
			max_radius, 
			filter,
			group_name
		) 
		if filter.is_valid() else 
		EntityManager.search_entities_in_ellipse(
			center, 
			min_radius, 
			max_radius, 
			group_name
		)
	)
	_sort_entities(targets, center)

	if max_search != Constants.UNSET and targets.size() > max_search:
		targets.resize(max_search)

	return targets


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


## 跳过注定死亡目标过滤器。
func _skip_doomed_filter(entity: Entity) -> bool:
	return not entity.meta_state & Entity.MetaState.DOOMED


## 跳过已死亡目标过滤器。
func _skip_dead_filter(entity: Entity) -> bool:
	return not entity.state & Entity.State.DEAD


func _packed_filters(entity: Entity, filters: Array[Callable]) -> bool:
	for filter: Callable in filters:
		if not filter.call(entity):
			return false

	return true


## 排序实体数组。
func _sort_entities(entity_array: Array[Entity], search_global_position: Vector2) -> void:
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
			entity_array.shuffle()
			return

	var priority_flags: int = 0
	for flag: InteractPolicy.Flag in interact_policy_flag_sort_priority:
		priority_flags |= flag
		
	sort_function = func(entity1: Entity, entity2: Entity) -> bool:
		var result: bool = true

		var interact_policy1: InteractPolicy = entity1.config.interact_policy
		var interact_policy2: InteractPolicy = entity2.config.interact_policy
		if (
			interact_policy1 and interact_policy2 and
			(
				interact_policy1.flags & priority_flags or interact_policy2.flags & priority_flags
			)
		):
			for flag: InteractPolicy.Flag in interact_policy_flag_sort_priority:
				if interact_policy1.flags & flag:
					break
				if interact_policy2.flags & flag:
					result = false
					break
		else:
			result = sort_function.call(entity1, entity2)

		return not result if sort_ascending_enabled else result
			
	entity_array.sort_custom(sort_function)


## 排序模式: 路程。
func _sort_by_progress(entity1: Entity, entity2: Entity) -> bool:
	var progress1: float = INF
	var progress2: float = INF

	var entity1_nav_path_c: NavPathComponent = entity1.get_node_or_null(Constants.NAV_PATH_COMPONENT_NODE_PATH)
	if entity1_nav_path_c:
		progress1 = entity1_nav_path_c.progress

	var entity2_nav_path_c: NavPathComponent = entity2.get_node_or_null(Constants.NAV_PATH_COMPONENT_NODE_PATH)
	if entity2_nav_path_c:
		progress2 = entity2_nav_path_c.progress

	return progress1 > progress2


## 排序模式: 血量。
func _sort_by_health(entity1: Entity, entity2: Entity) -> bool:
	var hp1: float = INF
	var hp2: float = INF

	var entity1_health_c: HealthComponent = entity1.get_node_or_null(Constants.HEALTH_COMPONENT_NODE_PATH)
	if entity1_health_c:
		hp1 = entity1_health_c.hp
	var entity2_health_c: HealthComponent = entity2.get_node_or_null(Constants.HEALTH_COMPONENT_NODE_PATH)
	if entity2_health_c:
		hp2 = entity2_health_c.hp

	return hp1 > hp2


## 排序模式: 赏金。
func _sort_by_gold(entity1: Entity, entity2: Entity) -> bool:
	var gold1: float = INF
	var gold2: float = INF

	var entity1_health_c: HealthComponent = entity1.get_node_or_null(Constants.HEALTH_COMPONENT_NODE_PATH)
	if entity1_health_c:
		gold1 = entity1_health_c.config.death_gold
	var entity2_health_c: HealthComponent = entity2.get_node_or_null(Constants.HEALTH_COMPONENT_NODE_PATH)
	if entity2_health_c:
		gold2 = entity2_health_c.config.death_gold

	return gold1 > gold2


## 排序模式: 距离。
func _sort_by_distance(entity1: Entity, entity2: Entity, search_global_position: Vector2) -> bool:
	var distance1: float = entity1.global_position.distance_squared_to(search_global_position)
	var distance2: float = entity2.global_position.distance_squared_to(search_global_position)

	return distance1 > distance2


## 排序模式: 近战伤害。
func _sort_by_melee_damage(entity1: Entity, entity2: Entity) -> bool:
	var melee_damage1: float = INF
	var melee_damage2: float = INF
	
	var entity1_melee_c: MeleeComponent = entity1.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
	if entity1_melee_c:
		var first_melee_skill := entity1_melee_c.get_child(0) as MeleeSkill
		if first_melee_skill:
			var damage_influence := first_melee_skill.config.influence as DamageInfluence
			if damage_influence:
				melee_damage1 = (damage_influence.min_value + damage_influence.damage_max) / 2.0
	var entity2_melee_c: MeleeComponent = entity2.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
	if entity2_melee_c:
		var first_melee_skill := entity2_melee_c.get_child(0) as MeleeSkill
		if first_melee_skill:
			var damage_influence := first_melee_skill.config.influence as DamageInfluence
			if damage_influence:
				melee_damage2 = (damage_influence.min_value + damage_influence.damage_max) / 2.0

	return melee_damage1 > melee_damage2


## 排序模式: 远程伤害。
func _sort_by_ranged_damage(entity1: Entity, entity2: Entity) -> bool:
	var ranged_damage1: float = INF
	var ranged_damage2: float = INF

	var entity1_skill_c: SkillComponent = entity1.get_node_or_null(Constants.SKILL_COMPONENT_NODE_PATH)
	if entity1_skill_c:
		var first_ranged_skill := entity1_skill_c.get_child(0) as RangedSkill
		if first_ranged_skill:
			var bullet_template: NodeConfigTemplateNode = NodeConfigManager.get_node_config_template_by_entity_uid(first_ranged_skill.config.bullet_scene)
			var bullet_c_config: BulletComponentNodeConfig = bullet_template.get_node_config(Constants.BULLET_COMPONENT_NODE_PATH)
			var damage_influence := bullet_c_config.hit_influence as DamageInfluence
			if damage_influence:
				ranged_damage1 = (damage_influence.min_value + damage_influence.damage_max) / 2.0
	var entity2_skill_c: SkillComponent = entity2.get_node_or_null(Constants.SKILL_COMPONENT_NODE_PATH)
	if entity2_skill_c:
		var first_ranged_skill := entity2_skill_c.get_child(0) as RangedSkill
		if first_ranged_skill:
			var bullet_template: NodeConfigTemplateNode = NodeConfigManager.get_node_config_template_by_entity_uid(first_ranged_skill.config.bullet_scene)
			var bullet_c_config: BulletComponentNodeConfig = bullet_template.get_node_config(Constants.BULLET_COMPONENT_NODE_PATH)
			var damage_influence := bullet_c_config.hit_influence as DamageInfluence
			if damage_influence:
				ranged_damage2 = (damage_influence.min_value + damage_influence.damage_max) / 2.0

	return ranged_damage1 > ranged_damage2


## 排序模式: 实体 ID。
func _sort_by_id(entity1: Entity, entity2: Entity) -> bool:
	var id1: int = entity1.id
	var id2: int = entity2.id
	
	return id1 > id2
