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
enum SearchGroup {
	## 搜索组: 无。
	NONE,
	## 搜索组：实体。
	ENTITY,
	## 搜索组: 敌人。
	ENEMY,
	## 搜索组: 友军。
	FRIENDLY,
	## 搜索组: 单位。
	UNIT,
	## 搜索组: 防御塔。
	TOWER,
}


## 中心偏移量。
@export var center_offsets: OffsetGroup = null:
	set(v): 
		center_offsets = v
		if Engine.is_editor_hint():
			U.connect_resource_changed(center_offsets, emit_changed)
			emit_changed()
## 最小半径。
@export var min_radius: float = 0.0:
	set(v): 
		min_radius = v
		if Engine.is_editor_hint():
			emit_changed()
## 最大半径。
@export var max_radius: float = 0.0:
	set(v): 
		max_radius = v
		if Engine.is_editor_hint():
			emit_changed()
## 最大搜索数量。
@export var max_search: int = C.UNSET
## 排序模式。
@export var sort_mode: SortMode = SortMode.PROGRESS
## 是否反转排序，默认最大在前，为 true 时最小在前。
@export var sort_reversed: bool = false
## 搜索组。
@export var search_group: SearchGroup = SearchGroup.ENEMY
## 搜索标识。
@export var search_flag: int = C.SearchFlag.NONE
## 交互策略。
@export var interact_policy: InteractPolicy = null


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"search_flag":
			property.hint_string = "mask_enum:SearchFlag"


## 搜索目标。
func search_targets(center: Vector2, e: Entity = null, filter: = Callable()) -> Array[Entity]:
	if e and center_offsets:
		var center_offset: Vector2 = center_offsets.get_offset_for_point(e.global_position, e.look_point)
		center += center_offset

	var group: StringName = &""
	var is_enemy: bool = e and e.interact_policy and e.interact_policy.flags & C.Flag.ENEMY

	match search_group:
		SearchGroup.ENTITY:
			group = C.GROUP_ENTITY
		SearchGroup.ENEMY:
			group = C.GROUP_FRIENDLY if is_enemy else C.GROUP_ENEMY
		SearchGroup.FRIENDLY:
			group = C.GROUP_ENEMY if is_enemy else C.GROUP_FRIENDLY
		SearchGroup.UNIT:
			group = C.GROUP_UNIT
		SearchGroup.TOWER:
			group = C.GROUP_TOWER
			
	var targets: Array = SearchMgr.find_targets_in_range(
		center, 
		max_radius, 
		min_radius, 
		interact_policy.flags if interact_policy else 0, 
		interact_policy.bans if interact_policy else 0,
		filter,
		group
	)
	_sort_entities_by_type(targets, center)
	if U.is_valid_number(max_search) and targets.size() > max_search:
		targets.resize(max_search)

	return targets


## 搜索单个目标。
func search_target(center: Vector2, e: Entity = null, filter: = Callable()) -> Entity:
	var targets: Array[Entity] = search_targets(center, e, filter)
	if targets:
		return targets[0]

	return null


## 根据搜索模式在扇形范围内搜索目标，filter 返回 false 表示被过滤。
func search_targets_in_sector(
		search_entity: Entity,
		origin: Vector2,
		look_at: Vector2,
		radius: float,
		angle_range: float,
		filter: Callable = Callable()
	) -> Array:
	var sector_filter: Callable = func(e: Entity) -> bool:
		return U.is_in_sector(
			origin, 
			e.global_position, 
			radius, 
			angle_range, 
			origin.angle_to(look_at)
		) and (not filter.is_valid() or filter.call(e))

	return search_targets(origin, search_entity, sector_filter)


## 根据搜索模式在矩形范围内搜索目标，filter 返回 false 表示被过滤。
func search_targets_in_rectangle(
		search_entity: Entity,
		origin: Vector2,
		look_at: Vector2,
		width: float,
		length: float,
		filter: Callable = Callable()
	) -> Array:
	var rectangle_filter: Callable = func(e: Entity) -> bool:
		return U.is_in_line(
			origin, 
			e.global_position, 
			width,
			length,
			origin.angle_to(look_at)
		) and (not filter.is_valid() or filter.call(e))

	return search_targets(origin, search_entity, rectangle_filter)


## 绘制搜索范围。
func draw(drawer: CanvasItem, center: Vector2) -> void:
	if center_offsets:
		U.draw_range_circle(drawer, center + center_offsets.right, min_radius, max_radius)

		OffsetGroup.draw_offset_group(drawer, center_offsets)
	else:
		U.draw_range_circle(drawer, center, min_radius, max_radius)


## 根据排序模式排序实体数组。
func _sort_entities_by_type(entities_array: Array[Entity], origin: Vector2) -> void:
	var sort_function: Callable = Callable()
	
	match sort_mode:
		SortMode.PROGRESS:
			sort_function = _sort_by_progress
		SortMode.HEALTH:
			sort_function = _sort_by_health
		SortMode.GOLD:
			sort_function = _sort_by_gold
		SortMode.DISTANCE:
			sort_function = _sort_by_distance.bind(origin)
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
func _sort_by_progress(e1: Entity, e2: Entity) -> bool:
	var p1: float = INF if sort_reversed else -INF
	var p2: float = INF if sort_reversed else -INF

	var e1_nav_c: NavPathComponent = e1.get_node_or_null(C.CN_NAV_PATH)
	if e1_nav_c:
		p1 = e1_nav_c.nav_progress

	var e2_nav_c: NavPathComponent = e2.get_node_or_null(C.CN_NAV_PATH)
	if e2_nav_c:
		p2 = e2_nav_c.nav_progress

	return p1 < p2 if sort_reversed else p1 > p2


## 排序模式: 血量。
func _sort_by_health(e1: Entity, e2: Entity) -> bool:
	var h1: float = INF if sort_reversed else -INF
	var h2: float = INF if sort_reversed else -INF

	var e1_health_c: HealthComponent = e1.get_node_or_null(C.CN_HEALTH)
	if e1_health_c:
		h1 = e1_health_c.hp
	var e2_health_c: HealthComponent = e2.get_node_or_null(C.CN_HEALTH)
	if e2_health_c:
		h2 = e2_health_c.hp

	return h1 < h2 if sort_reversed else h1 > h2


## 排序模式: 赏金。
func _sort_by_gold(e1: Entity, e2: Entity) -> bool:
	var g1: float = INF if sort_reversed else -INF
	var g2: float = INF if sort_reversed else -INF

	var e1_health_c: HealthComponent = e1.get_node_or_null(C.CN_HEALTH)
	if e1_health_c:
		g1 = e1_health_c.death_gold
	var e2_health_c: HealthComponent = e2.get_node_or_null(C.CN_HEALTH)
	if e2_health_c:
		g2 = e2_health_c.death_gold

	return g1 < g2 if sort_reversed else g1 > g2


## 排序模式: 距离。
func _sort_by_distance(e1: Entity, e2: Entity, origin: Vector2) -> bool:
	var d1: float = e1.global_position.distance_squared_to(origin)
	var d2: float = e2.global_position.distance_squared_to(origin)

	return d1 < d2 if sort_reversed else d1 > d2


## 排序模式: 近战伤害。
func _sort_by_melee_damage(e1: Entity, e2: Entity) -> bool:
	var d1: float = INF if sort_reversed else -INF
	var d2: float = INF if sort_reversed else -INF
	
	var e1_melee_c: MeleeComponent = e1.get_node_or_null(C.CN_MELEE)
	if e1_melee_c:
		var first_skill: MeleeSkill = e1_melee_c.get_child(0)
		var influence: Influence = first_skill.influence

		if influence:
			d1 = influence.damage_max
	var e2_melee_c: MeleeComponent = e2.get_node_or_null(C.CN_MELEE)
	if e2_melee_c:
		var first_skill: MeleeSkill = e2_melee_c.get_child(0)
		var influence: Influence = first_skill.influence

		if influence:
			d2 = influence.damage_max

	return d1 < d2 if sort_reversed else d1 > d2


## 排序模式: 远程伤害。
func _sort_by_ranged_damage(e1: Entity, e2: Entity) -> bool:
	var d1: float = INF if sort_reversed else -INF
	var d2: float = INF if sort_reversed else -INF

	var e1_skill_c: SkillComponent = e1.get_node_or_null(C.CN_SKILL)
	if e1_skill_c:
		var first_skill: Skill = e1_skill_c.get_child(0)
		var influence: Influence = first_skill.influence

		if influence:
			d1 = influence.damage_max
	var e2_skill_c: SkillComponent = e2.get_node_or_null(C.CN_SKILL)
	if e2_skill_c:
		var first_skill: Skill = e2_skill_c.get_child(0)
		var influence: Influence = first_skill.influence

		if influence:
			d2 = influence.damage_max

	return d1 < d2 if sort_reversed else d1 > d2


## 排序模式: 实体 ID。
func _sort_by_id(e1: Entity, e2: Entity) -> bool:
	var i1: int = e1.id
	var i2: int = e2.id
	
	return i1 < i2 if sort_reversed else i1 > i2
