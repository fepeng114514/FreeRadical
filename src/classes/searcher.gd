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
enum Flag {
	## 搜索标识: 无。
	NONE = 0,
	## 搜索标识: 跳过即将死亡的目标。
	SKIP_READY_DEAD = 1,
}


## 中心偏移量。
@export var center_offsets: OffsetGroup = null:
	set(v): 
		Utils.rebind_changed(center_offsets, v, emit_changed)
		center_offsets = v
		emit_changed()
## 最小半径。
@export var min_radius: float = 0.0:
	set(v): 
		min_radius = v
		emit_changed()
## 最大半径。
@export var max_radius: float = 0.0:
	set(v): 
		max_radius = v
		emit_changed()
## 最大搜索数量。
@export var max_search: int = Constants.UNSET
## 排序模式。
@export var sort_mode: SortMode = SortMode.PROGRESS
## 是否启用反转排序，默认最大在前，为 [code]true[/code] 时最小在前。
@export var sort_reversed_enabled: bool = false
## 搜索组。
@export var searched_group: SearchedGroup = SearchedGroup.ENEMIES
## 搜索标识。
@export var search_flag: int = Flag.NONE
## 交互策略。
@export var interact_policy: InteractPolicy = null

var _init_connect_property_signals: Dictionary[String, Callable] = {
	"center_offsets": emit_changed,
}


func _init() -> void:
	resource_local_to_scene = true
	Utils.connect_property_signals(self, _init_connect_property_signals)


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"search_flag":
			property.hint_string = "mask_check(%s)" % Flag


## 搜索目标。
func search_targets(center: Vector2, search_entity: Entity = null, filter := Callable()) -> Array[Entity]:
	if search_entity and center_offsets:
		var center_offset: Vector2 = center_offsets.get_offset_toward_point(search_entity.global_position, search_entity.facing_global_position)
		center += center_offset

	var is_enemy: bool = search_entity and search_entity.interact_policy and search_entity.interact_policy.flags & InteractPolicy.Flag.ENEMY
	var group_name: StringName = &""
	match searched_group:
		SearchedGroup.ENTITIES:
			group_name = Constants.GROUP_ENTITIES
		SearchedGroup.ENEMIES:
			group_name = Constants.GROUP_FRIENDLIES if is_enemy else Constants.GROUP_ENEMIES	
		SearchedGroup.FRIENDLIES:
			group_name = Constants.GROUP_ENEMIES if is_enemy else Constants.GROUP_FRIENDLIES
		SearchedGroup.UNITS:
			group_name = Constants.GROUP_UNITS
		SearchedGroup.TOWERS:
			group_name = Constants.GROUP_TOWERS

	var extra_filter := Callable()
	match search_flag:
		Flag.SKIP_READY_DEAD:
			extra_filter = _skip_ready_dead_filter.bind()
			
	if extra_filter.is_valid():
		filter = func(entity: Entity) -> bool: 
			return filter.call(entity) and extra_filter.call(entity)
			
	var targets: Array[Entity] = EntityManager.search_entities_in_ellipse(
		center, 
		min_radius, 
		max_radius, 
		filter,
		group_name
	)
	_sort_entities_by_type(targets, center)
	if Utils.is_valid_number(max_search) and targets.size() > max_search:
		targets.resize(max_search)

	var result: Array[Entity] = []
	result.assign(targets)
	return result


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


## 跳过已死亡目标过滤器。
func _skip_ready_dead_filter(entity: Entity) -> bool:
	var health_c: HealthComponent = entity.get_node_or_null(Constants.CN_HEALTH)
	if health_c:
		var total_damage: float = 0.0

		for bullet_id: int in entity.target_bullet_id_list:
			var bullet: Entity = EntityManager.get_entity_by_id(bullet_id)
			var bullet_c: BulletComponent = bullet.get_node_or_null(Constants.CN_BULLET)
			if not bullet_c:
				continue

			var damage_influence := bullet_c.influence as DamageInfluence
			if not damage_influence:
				continue
		
			var damage: Damage = Damage.new()
			match damage_influence.get_value_mode:
				damage_influence.GetValueMode.RANDOM:
					damage.value = damage_influence.override_value
				damage_influence.GetValueMode.ELLIPTICAL_FALLOFF:
					damage.value = damage_influence.max_value
			damage.damage_type = damage_influence.damage_type
			damage.damage_flags = damage_influence.damage_flags

			var actual_damage: float = damage.predict_damage(entity)
			total_damage += actual_damage
			if total_damage >= health_c.hp:
				return false
				
	return true


## 根据排序模式排序实体数组。
func _sort_entities_by_type(entities_array: Array[Entity], search_global_position: Vector2) -> void:
	var sort_function: Callable = Callable()
	
	match sort_mode:
		SortMode.PROGRESS:
			sort_function = _sort_by_progress
		SortMode.HEALTH:
			sort_function = _sort_by_health
		SortMode.GOLD:
			sort_function = _sort_by_gold
		SortMode.DISTANCE:
			sort_function = _sort_by_distance.bind(search_global_position)
		SortMode.MELEE_DAMAGE:
			sort_function = _sort_by_melee_damage
		SortMode.RANGED_DAMAGE:
			sort_function = _sort_by_ranged_damage
		SortMode.ID:
			sort_function = _sort_by_id
		SortMode.RANDOM:
			entities_array.shuffle()
			return
			
	entities_array.sort_custom(sort_function)


## 排序模式: 路程。
func _sort_by_progress(entity1: Entity, entity2: Entity) -> bool:
	var progress1: float = INF if sort_reversed_enabled else -INF
	var progress2: float = INF if sort_reversed_enabled else -INF

	var entity1_nav_path_c: NavPathComponent = entity1.get_node_or_null(Constants.CN_NAV_PATH)
	if entity1_nav_path_c:
		progress1 = entity1_nav_path_c.progress

	var entity2_nav_path_c: NavPathComponent = entity2.get_node_or_null(Constants.CN_NAV_PATH)
	if entity2_nav_path_c:
		progress2 = entity2_nav_path_c.progress

	return progress1 < progress2 if sort_reversed_enabled else progress1 > progress2


## 排序模式: 血量。
func _sort_by_health(entity1: Entity, entity2: Entity) -> bool:
	var hp1: float = INF if sort_reversed_enabled else -INF
	var hp2: float = INF if sort_reversed_enabled else -INF

	var entity1_health_c: HealthComponent = entity1.get_node_or_null(Constants.CN_HEALTH)
	if entity1_health_c:
		hp1 = entity1_health_c.hp
	var entity2_health_c: HealthComponent = entity2.get_node_or_null(Constants.CN_HEALTH)
	if entity2_health_c:
		hp2 = entity2_health_c.hp

	return hp1 < hp2 if sort_reversed_enabled else hp1 > hp2


## 排序模式: 赏金。
func _sort_by_gold(entity1: Entity, entity2: Entity) -> bool:
	var gold1: float = INF if sort_reversed_enabled else -INF
	var gold2: float = INF if sort_reversed_enabled else -INF

	var entity1_health_c: HealthComponent = entity1.get_node_or_null(Constants.CN_HEALTH)
	if entity1_health_c:
		gold1 = entity1_health_c.death_gold
	var entity2_health_c: HealthComponent = entity2.get_node_or_null(Constants.CN_HEALTH)
	if entity2_health_c:
		gold2 = entity2_health_c.death_gold

	return gold1 < gold2 if sort_reversed_enabled else gold1 > gold2


## 排序模式: 距离。
func _sort_by_distance(entity1: Entity, entity2: Entity, search_global_position: Vector2) -> bool:
	var distance1: float = entity1.global_position.distance_squared_to(search_global_position)
	var distance2: float = entity2.global_position.distance_squared_to(search_global_position)

	return distance1 < distance2 if sort_reversed_enabled else distance1 > distance2


## 排序模式: 近战伤害。
func _sort_by_melee_damage(entity1: Entity, entity2: Entity) -> bool:
	var melee_damage1: float = INF if sort_reversed_enabled else -INF
	var melee_damage2: float = INF if sort_reversed_enabled else -INF
	
	var entity1_melee_c: MeleeComponent = entity1.get_node_or_null(Constants.CN_MELEE)
	if entity1_melee_c:
		var first_skill: MeleeSkill = entity1_melee_c.get_child(0)
		var damage_influence := first_skill.influence as DamageInfluence

		if damage_influence:
			melee_damage1 = (damage_influence.min_value + damage_influence.damage_max) / 2.0
	var entity2_melee_c: MeleeComponent = entity2.get_node_or_null(Constants.CN_MELEE)
	if entity2_melee_c:
		var first_skill: MeleeSkill = entity2_melee_c.get_child(0)
		var damage_influence := first_skill.influence as DamageInfluence

		if damage_influence:
			melee_damage2 = (damage_influence.min_value + damage_influence.damage_max) / 2.0

	return melee_damage1 < melee_damage2 if sort_reversed_enabled else melee_damage1 > melee_damage2


## 排序模式: 远程伤害。
func _sort_by_ranged_damage(entity1: Entity, entity2: Entity) -> bool:
	var ranged_damage1: float = INF if sort_reversed_enabled else -INF
	var ranged_damage2: float = INF if sort_reversed_enabled else -INF

	var entity1_skill_c: SkillComponent = entity1.get_node_or_null(Constants.CN_SKILL)
	if entity1_skill_c:
		var first_skill: Skill = entity1_skill_c.get_child(0)
		var damage_influence := first_skill.influence as DamageInfluence

		if damage_influence:
			ranged_damage1 = (damage_influence.min_value + damage_influence.damage_max) / 2.0
	var entity2_skill_c: SkillComponent = entity2.get_node_or_null(Constants.CN_SKILL)
	if entity2_skill_c:
		var first_skill: Skill = entity2_skill_c.get_child(0)
		var damage_influence := first_skill.influence as DamageInfluence

		if damage_influence:
			ranged_damage2 = (damage_influence.min_value + damage_influence.damage_max) / 2.0

	return ranged_damage1 < ranged_damage2 if sort_reversed_enabled else ranged_damage1 > ranged_damage2


## 排序模式: 实体 ID。
func _sort_by_id(entity1: Entity, entity2: Entity) -> bool:
	var id1: int = entity1.id
	var id2: int = entity2.id
	
	return id1 < id2 if sort_reversed_enabled else id1 > id2
