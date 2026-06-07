extends Node
## 搜索管理器。
##
## 负责搜索实体的相关操作。


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


## 空间索引的网格大小。
const SPACE_INDEX_GRID_SIZE: float = 100


#region 属性
## 空间索引列数。
var space_index_grid_count_x: int = 0
## 空间索引行数。
var space_index_grid_count_y: int = 0
## 空间索引网格数组。
var space_index_grid_list: Array[Dictionary] = []
#endregion


func _load() -> void:
	var world_size: Vector2 = GlobalMgr.world_size
	var grid_count_x: int = ceili(world_size.x / SPACE_INDEX_GRID_SIZE)
	var grid_count_y: int = ceili(world_size.y / SPACE_INDEX_GRID_SIZE)
	
	for x: int in grid_count_x:
		var grid_col: Dictionary = {
			"row": [],
			"has_entities": false,
			"has_enemies": false,
			"has_friendlys": false,
			"has_units": false,
			"has_towers": false,
			"has_modifiers": false,
			"has_auras": false,
		}
		var grid_row: Array = grid_col.row

		for y: int in grid_count_y:
			grid_row.append({
				C.GROUP_ENTITIES: [],
				C.GROUP_ENEMIES: [],
				C.GROUP_FRIENDLYS: [],
				C.GROUP_UNIT: [],
				C.GROUP_TOWERS: [],
				C.GROUP_MODIFIERS: [],
				C.GROUP_AURAS: [],
			})

		space_index_grid_list.append(grid_col)
	
	space_index_grid_count_x = grid_count_x
	space_index_grid_count_y = grid_count_y


## 根据排序模式排序实体数组，默认最大在前，如果 reversed 为 true 则最小在前。
func sort_entities_by_type(
		entities_array: Array[Entity], sort_type: SortMode, origin: Vector2, reversed: bool = false
	) -> void:
	var sort_function: Callable = Callable()
	
	match sort_type:
		SortMode.PROGRESS:
			sort_function = _sort_by_progress.bind(reversed)
		SortMode.HEALTH:
			sort_function = _sort_by_health.bind(reversed)
		SortMode.GOLD:
			sort_function = _sort_by_gold.bind(reversed)
		SortMode.DISTANCE:
			sort_function = _sort_by_distance.bind(origin, reversed)
		SortMode.MELEE_DAMAGE:
			sort_function = _sort_by_melee_damage.bind(reversed)
		SortMode.RANGED_DAMAGE:
			sort_function = _sort_by_ranged_damage.bind(reversed)
		SortMode.ID:
			sort_function = _sort_by_id.bind(reversed)
		SortMode.RANDOM:
			entities_array.shuffle()
			return
			
	entities_array.sort_custom(sort_function)


## 排序模式: 路程。
static func _sort_by_progress(e1: Entity, e2: Entity, reversed: bool) -> bool:
	var p1: float = INF if reversed else -INF
	var p2: float = INF if reversed else -INF

	var e1_nav_c: NavPathComponent = e1.get_node_or_null(C.CN_NAV_PATH)
	if e1_nav_c:
		p1 = e1_nav_c.nav_progress

	var e2_nav_c: NavPathComponent = e2.get_node_or_null(C.CN_NAV_PATH)
	if e2_nav_c:
		p2 = e2_nav_c.nav_progress

	return p1 > p2 if not reversed else p1 < p2


## 排序模式: 血量。
static func _sort_by_health(e1: Entity, e2: Entity, reversed: bool) -> bool:
	var h1: float = INF if reversed else -INF
	var h2: float = INF if reversed else -INF

	var e1_health_c: HealthComponent = e1.get_node_or_null(C.CN_HEALTH)
	if e1_health_c:
		h1 = e1_health_c.hp
	var e2_health_c: HealthComponent = e2.get_node_or_null(C.CN_HEALTH)
	if e2_health_c:
		h2 = e2_health_c.hp

	return h1 > h2 if not reversed else h1 < h2


## 排序模式: 赏金。
static func _sort_by_gold(e1: Entity, e2: Entity, reversed: bool) -> bool:
	var g1: float = INF if reversed else -INF
	var g2: float = INF if reversed else -INF

	var e1_health_c: HealthComponent = e1.get_node_or_null(C.CN_HEALTH)
	if e1_health_c:
		g1 = e1_health_c.death_gold
	var e2_health_c: HealthComponent = e2.get_node_or_null(C.CN_HEALTH)
	if e2_health_c:
		g2 = e2_health_c.death_gold

	return g1 > g2 if not reversed else g1 < g2


## 排序模式: 距离。
static func _sort_by_distance(e1: Entity, e2: Entity, origin: Vector2, reversed: bool) -> bool:
	var d1: float = e1.global_position.distance_squared_to(origin)
	var d2: float = e2.global_position.distance_squared_to(origin)

	return d1 > d2 if not reversed else d1 < d2


## 排序模式: 近战伤害。
static func _sort_by_melee_damage(e1: Entity, e2: Entity, reversed: bool) -> bool:
	var d1: float = INF if reversed else -INF
	var d2: float = INF if reversed else -INF
	
	var e1_melee_c: MeleeComponent = e1.get_node_or_null(C.CN_MELEE)
	if e1_melee_c:
		var first_skill: SkillMelee = e1_melee_c.get_child(0)
		var influence: InfluenceResource = first_skill.influence

		if influence:
			d1 = influence.damage_max
	var e2_melee_c: MeleeComponent = e2.get_node_or_null(C.CN_MELEE)
	if e2_melee_c:
		var first_skill: SkillMelee = e2_melee_c.get_child(0)
		var influence: InfluenceResource = first_skill.influence

		if influence:
			d2 = influence.damage_max

	return d1 > d2 if not reversed else d1 < d2


## 排序模式: 远程伤害。
static func _sort_by_ranged_damage(e1: Entity, e2: Entity, reversed: bool) -> bool:
	var d1: float = INF if reversed else -INF
	var d2: float = INF if reversed else -INF

	var e1_skill_c: SkillComponent = e1.get_node_or_null(C.CN_SKILL)
	if e1_skill_c:
		var first_skill: Skill = e1_skill_c.get_child(0)
		var influence: InfluenceResource = first_skill.influence

		if influence:
			d1 = influence.damage_max
	var e2_skill_c: SkillComponent = e2.get_node_or_null(C.CN_SKILL)
	if e2_skill_c:
		var first_skill: Skill = e2_skill_c.get_child(0)
		var influence: InfluenceResource = first_skill.influence

		if influence:
			d2 = influence.damage_max

	return d1 > d2 if not reversed else d1 < d2


## 排序模式: 实体 ID。
static func _sort_by_id(e1: Entity, e2: Entity, reversed: bool) -> bool:
	var i1: int = e1.id
	var i2: int = e2.id
	
	return i1 > i2 if not reversed else i1 < i2


#region 实体的搜索模式配置
## 搜索模式配置类。
class SearchModeConfig:
	var sort_mode: SortMode
	var group: StringName
	var reversed: bool

	func _init(p_sort: SortMode, p_group: StringName, p_rev: bool):
		sort_mode = p_sort
		group = p_group
		reversed = p_rev


## 搜索模式配置构建器。
class SearchConfigBuilder:
	## 实体分组字典。
	const GROUP_DICT: Dictionary[String, StringName] = {
		"ENTITY": C.GROUP_ENTITIES,
		"ENEMY": C.GROUP_ENEMIES,
		"FRIENDLY": C.GROUP_FRIENDLYS,
		"UNIT": C.GROUP_UNIT,
	}
	## 排序模式属性元数据列表。
	const search_mode_meta_list: Array[Dictionary] = [
		{"name": "PROGRESS", "sort_mode": SortMode.PROGRESS, "has_reverse_mode": true},
		{"name": "DISTANCE", "sort_mode": SortMode.DISTANCE, "has_reverse_mode": true},
		{"name": "HEALTH", "sort_mode": SortMode.HEALTH, "has_reverse_mode": true},
		{"name": "MELEE_DAMAGE", "sort_mode": SortMode.MELEE_DAMAGE, "has_reverse_mode": true},
		{"name": "RANGED_DAMAGE", "sort_mode": SortMode.RANGED_DAMAGE, "has_reverse_mode": true},
		{"name": "ID", "sort_mode": SortMode.ID, "has_reverse_mode": true},
		{"name": "GOLD", "sort_mode": SortMode.GOLD, "has_reverse_mode": true},
		{"name": "RANDOM", "sort_mode": SortMode.RANDOM, "has_reverse_mode": false},
	]

	## 构建搜索模式配置字典。
	static func build_search_config() -> Dictionary[C.SearchMode, SearchModeConfig]:
		var config: Dictionary[C.SearchMode, SearchModeConfig] = {}

		for group: String in GROUP_DICT:
			var group_name: StringName = GROUP_DICT[group]

			for search_mode_meta: Dictionary in search_mode_meta_list:
				var sort: SortMode = search_mode_meta["sort_mode"]
				
				if search_mode_meta["has_reverse_mode"]:
					# MAX 模式：降序 = false
					var max_mode_name: String = "%s_%s_%s" % [group, "MAX", search_mode_meta["name"]]
					config[C.SearchMode[max_mode_name]] = SearchModeConfig.new(sort, group_name, false)
					
					# MIN 模式：降序 = true
					var min_mode_name: String = "%s_%s_%s" % [group, "MIN", search_mode_meta["name"]]
					config[C.SearchMode[min_mode_name]] = SearchModeConfig.new(sort, group_name, true)
				else:
					# 无反转模式
					var mode_name: String = "%s_%s" % [group, search_mode_meta["name"]]
					config[C.SearchMode[mode_name]] = SearchModeConfig.new(sort, group_name, false)
				
		return config


## 搜索模式配置字典。
var search_config: Dictionary[C.SearchMode, SearchModeConfig] = SearchConfigBuilder.build_search_config()


## 搜索范围内目标。
##
## filter 返回 false 表示被过滤。
func find_targets_in_range(
		origin: Vector2,
		max_range: float,
		min_range: float = 0.0,
		flags: int = 0,
		bans: int = 0,
		filter: Callable = Callable(),
		group: StringName = C.GROUP_ENTITIES
	) -> Array[Entity]:
	var targets: Array[Entity] = []

	var grid_min_x: int = max(0, floori((origin.x - max_range) / SPACE_INDEX_GRID_SIZE))
	var grid_max_x: int = min(space_index_grid_count_x - 1, ceili((origin.x + max_range) / SPACE_INDEX_GRID_SIZE))
	var grid_min_y: int = max(0, floori((origin.y - max_range) / SPACE_INDEX_GRID_SIZE))
	var grid_max_y: int = min(space_index_grid_count_y - 1, ceili((origin.y + max_range) / SPACE_INDEX_GRID_SIZE))

	for grid_x: int in range(grid_min_x, grid_max_x + 1):
		var grid_col: Dictionary = space_index_grid_list[grid_x]

		if not grid_col["has_" + group]:
			continue

		var grid_row: Array = grid_col.row

		for grid_y: int in range(grid_min_y, grid_max_y + 1):
			var grid: Array = grid_row[grid_y][group]
			for e: Entity in grid:
				var interact_p: InteractPolicy = e.interact_policy
				
				if (
						(not interact_p or not U.is_mutual_banned(interact_p.flags, bans, flags, interact_p.bans))
						and U.is_in_ring(origin, e.global_position, min_range, max_range)
						and (not filter.is_valid() or filter.call(e))
				):
					targets.append(e)

	return targets
#endregion


## 根据搜索模式选择相应索敌函数（搜索范围内单个目标）。
##	
## filter 返回 false 表示被过滤。
func search_targets(
		search_mode: C.SearchMode, 
		origin: Vector2, 
		max_range: float, 
		min_range: float = 0.0, 
		flags: int = 0, 
		bans: int = 0, 
		filter: Callable = Callable()
	) -> Array[Entity]:
	var config: SearchModeConfig = search_config.get(search_mode)
	if not config:
		Log.error("未知搜索模式: %s" % search_mode)
		return []

	var group: StringName = config.group

	if flags & C.Flag.ENEMY:
		match config.group:
			C.GROUP_ENEMIES:
				group = C.GROUP_FRIENDLYS
			C.GROUP_FRIENDLYS:
				group = C.GROUP_ENEMIES
			
	var targets: Array = find_targets_in_range(
		origin, max_range, min_range, flags, bans, filter, group
	)
	sort_entities_by_type(targets, config.sort_mode, origin, config.reversed)
	return targets


## 根据搜索模式在扇形范围内搜索目标。
##
## filter 返回 false 表示被过滤。
func search_targets_in_sector(
		search_mode: C.SearchMode,
		origin: Vector2,
		look_at: Vector2,
		radius: float,
		angle_range: float,
		flags: int = 0,
		bans: int = 0,
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

	return search_targets(
		search_mode, origin, radius, 0, flags, bans, sector_filter
	)


## 根据搜索模式在矩形范围内搜索目标。
##
## filter 返回 false 表示被过滤。
func search_targets_in_rectangle(
		search_mode: C.SearchMode,
		origin: Vector2,
		look_at: Vector2,
		width: float,
		length: float,
		flags: int = 0,
		bans: int = 0,
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

	return search_targets(
		search_mode, origin, length, 0, flags, bans, rectangle_filter
	)