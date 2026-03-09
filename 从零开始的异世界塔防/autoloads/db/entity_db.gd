extends Node


"""实体数据库:
	存储所有实体与相关数据
	待优化:
		1. 索敌的空间索引优化
		2. 对象池
"""

#region 属性
## 存储实体场景的字典
var _entity_scenes: Dictionary[C.ENTITY_TAG, PackedScene] = {}
## 被修改的场景
var _dirty_scenes: Array[C.ENTITY_TAG] = []
## 存储实体类型组的字典
var _type_groups: Dictionary[String, Array] = {
	"enemies": [],
	"friendlys": [],
	"unit": [],
	"towers": [],
	"modifiers": [],
	"auras": [],
}
## 存储组件组的字典
var _component_groups: Dictionary[String, Array] = {}
## 所有实体数组
var _entities: Array = []
## 下一个创建实体的 id
var _next_id: int = 0
## 被修改的实体 id
var _dirty_entities_ids: Array[int] = []
## 实体数据缓存字典，用于读取数据，不参与游戏
var _cached_entities_data: Dictionary[C.ENTITY_TAG, Entity] = {}
## 实体标签名称字典
var tag_name_dict: Dictionary[C.ENTITY_TAG, String]
#endregion


func load() -> void:
	_entity_scenes.clear()
	for group in _type_groups.values():
		group.clear()
	_component_groups.clear()
	_entities.clear()
	_dirty_entities_ids.clear()
	tag_name_dict.clear()
	_next_id = 0
	_cached_entities_data.clear()
	
	_load_tag_name_dict()
	_load_entity_scenes()

## 加载实体场景
func _load_entity_scenes() -> void:
	for entity_tag: C.ENTITY_TAG in C.ENTITY_TAG.values():
		var t_name: String = get_tag_name(entity_tag)
		var scene_path: String = C.PATH_ENTITIES_SCENES % t_name
		if not ResourceLoader.exists(scene_path):
			Log.error("未找到实体场景: %s" % scene_path)
			return
			
		var scene: PackedScene = load(scene_path)
		
		_entity_scenes[entity_tag] = scene

func _load_tag_name_dict() -> void:
	for entity_name: String in C.ENTITY_TAG.keys():
		var tag: C.ENTITY_TAG = C.ENTITY_TAG[entity_name]
		entity_name = entity_name.to_lower()
		tag_name_dict[tag] = entity_name


func get_tag_name(entity_tag: C.ENTITY_TAG) -> String:
	return tag_name_dict[entity_tag]


## 标记新增加或移除的实体
func mark_entity_dirty_id(id: int) -> void:
	if _dirty_entities_ids.has(id):
		return
		
	_dirty_entities_ids.append(id)


#region 创建实体相关
## 创建实体
func create_entity(entity_tag: C.ENTITY_TAG) -> Entity:
	var e: Entity = get_entity_scene(entity_tag).instantiate()
		
	return process_create(e)
	
	
## 处理创建
func process_create(e: Entity) -> Entity:
	e.id = _next_id
	e.name = "%sI%d" % [e.name, e.id]

	Log.debug("创建实体: %s" % e)
	_next_id += 1
		
	return e


## 批量创建实体
func create_entities(
		entity_tags: Array[C.ENTITY_TAG],
		config_func: Callable = Callable(),
		auto_insert: bool = true
	) -> Array[Entity]:
	
	var created_entities: Array[Entity] = []
	
	for entity_tag: C.ENTITY_TAG in entity_tags:
		var e: Entity = create_entity(entity_tag)
		
		if config_func.is_valid():
			config_func.call(e)
		
		if auto_insert:
			e.insert_entity()
		
		created_entities.append(e)
	
	return created_entities


## 创建实体在指定位置
func create_entities_at_pos(
		entity_tags: Array[C.ENTITY_TAG], pos: Vector2, auto_insert: bool = true
	) -> Array[Entity]:
	return create_entities(
		entity_tags, func(e): e.set_pos(pos), auto_insert
	)


## 批量创建状态效果实体
func create_mods(
		target_id: int,
		mods_tags: Array[C.ENTITY_TAG],
		source_id: int = C.UNSET,
		auto_insert: bool = true
	) -> Array[Entity]:
	
	return create_entities(mods_tags, func(e):
		e.target_id = target_id
		e.source_id = source_id
	, auto_insert)


## 批量创建光环实体
func create_auras(
		auras_tags: Array[C.ENTITY_TAG],
		source_id: int = C.UNSET,
		auto_insert: bool = true
	) -> Array[Entity]:
	
	return create_entities(auras_tags, func(e: Entity) -> void:
		e.source_id = source_id
	, auto_insert)

## 创建伤害实体
func create_damage(
		target_id: int,
		min_damage: float,
		max_damage: float,
		damage_type: C.DAMAGE = C.DAMAGE.PHYSICAL,
		source_id: int = C.UNSET,
		damage_factor: float = 1
	) -> Damage:
	var d := Damage.new()
	
	d.target_id = target_id
	d.source_id = source_id
	d.damage_type = damage_type
	d.value = randf_range(min_damage, max_damage)
	d.damage_factor = damage_factor
	d.tag_name = "damage"

	SystemMgr.damage_queue.append(d)
		
	return d
#endregion


#region 索引相关
## 根据组名获取组内所有实体
func get_entities_group(group_name: String) -> Array:
	if group_name in _type_groups:
		return _type_groups[group_name]
	
	if group_name in _component_groups:
		return _component_groups[group_name]

	return []


## 根据 id 索引实体
func get_entity_by_id(id: int) -> Entity:
	if not U.is_valid_number(id):
		return null

	var e = _entities.get(id)

	if not U.is_vaild_entity(e):
		return null

	return e


## 获取实体场景
func get_entity_scene(entity_tag: C.ENTITY_TAG) -> PackedScene:
	if not _entity_scenes.has(entity_tag):
		Log.error("未找到实体场景, tag: %d" % entity_tag)
		return null
		
	var scene: PackedScene = _entity_scenes[entity_tag]
		
	return scene
	

## 设置实体场景
func set_entity_scene(
		entity_tag: C.ENTITY_TAG, scene: PackedScene, new_scene_node: Entity
	) -> void:
	scene.pack(new_scene_node)
	EntityDB._dirty_scenes.append(entity_tag)
	_dirty_scenes.append(entity_tag)


## 获取所有有效实体
func get_vaild_entities() -> Array:
	return _entities.filter(
		func(e) -> bool: return U.is_vaild_entity(e)
	)
	
	
## 获取 source_id 为指定 id 的实体
func get_entities_by_source(source_id: int):
	return get_vaild_entities().filter(
		func(e: Entity) -> bool:
			return e.source_id == source_id
	)


## 获取实体数据，实体数据是一个实体实例，仅用于读取数据，不参与游戏逻辑
func get_entity_data(entity_tag: C.ENTITY_TAG) -> Entity:
	# 缓存机制：如果缓存中没有对应实体数据，则实例化一个新的实体并缓存
	if (
			not _cached_entities_data.has(entity_tag) 
			or entity_tag in _dirty_scenes
		):
		var e: Entity = get_entity_scene(entity_tag).instantiate()
		_cached_entities_data[entity_tag] = e
		_dirty_scenes.erase(entity_tag)

	return _cached_entities_data[entity_tag]
#endregion


#region 索敌相关
static func sort_entities_by_progress(entities_array: Array, reversed: bool = false) -> void:
	entities_array.sort_custom(func(e1: Entity, e2: Entity) -> bool:
		var p1: float = (
			e1.get_c(C.CN_NAV_PATH).nav_progress
			if e1.has_c(C.CN_NAV_PATH) else 0
		)
		var p2: float = (
			e2.get_c(C.CN_NAV_PATH).nav_progress
			if e2.has_c(C.CN_NAV_PATH) else 0
		)
		return p1 > p2 if not reversed else p1 < p2
	)


static func sort_entities_by_distance(
		entities_array: Array, origin: Vector2, reversed: bool = false
	) -> void:
	entities_array.sort_custom(func(e1: Entity, e2: Entity) -> bool:
		var d1: float = e1.global_position.distance_squared_to(origin)
		var d2: float = e2.global_position.distance_squared_to(origin)
		return d1 > d2 if not reversed else d1 < d2
	)


static func sort_entities_by_health(entities_array: Array, reversed: bool = false) -> void:
	entities_array.sort_custom(func(e1: Entity, e2: Entity) -> bool:
		var h1: float = (
			e1.get_c(C.CN_HEALTH).hp if e1.has_c(C.CN_HEALTH) else 0
		)
		var h2: float = (
			e2.get_c(C.CN_HEALTH).hp if e2.has_c(C.CN_HEALTH) else 0
		)
		return h1 > h2 if not reversed else h1 < h2
	)


static func sort_entities_by_melee_damage(entities_array: Array, reversed: bool = false) -> void:
	entities_array.sort_custom(func(e1: Entity, e2: Entity) -> bool:
		var d1: float = (
			e1.get_c(C.CN_MELEE).list[0].max_damage if e1.has_c(C.CN_MELEE) else 0
		)
		var d2: float = (
			e2.get_c(C.CN_MELEE).list[0].max_damage if e2.has_c(C.CN_MELEE) else 0
		)
		return d1 > d2 if not reversed else d1 < d2
	)


static func sort_entities_by_range_damage(entities_array: Array, reversed: bool = false) -> void:
	entities_array.sort_custom(func(e1: Entity, e2: Entity) -> bool:
		var d1: float = (
			EntityDB.get_entity_data(
				e1.get_c(C.CN_RANGED).list[0].bullet
			).get_c(C.CN_BULLET).max_damage if e1.has_c(C.CN_RANGED) else 0
		)
		var d2: float = (
			EntityDB.get_entity_data(
				e2.get_c(C.CN_RANGED).list[0].bullet
			).get_c(C.CN_BULLET).max_damage if e2.has_c(C.CN_RANGED) else 0
		)
		return d1 > d2 if not reversed else d1 < d2
	)


static func sort_entities_by_id(entities_array: Array, reversed: bool = false) -> void:
	entities_array.sort_custom(func(e1: Entity, e2: Entity) -> bool:
		var i1: int = e1.id
		var i2: int = e2.id
		return i1 > i2 if not reversed else i1 < i2
	)


## 根据排序模式排序实体，默认最大在前，如果 reversed 为 true 则最小在前
static func sort_entities_by_type(
		entities_array: Array, sort_type: C.SORT, origin: Vector2, reversed: bool = false
	) -> void:
	var sort_functions: Dictionary[C.SORT, Callable] = {
		C.SORT.PROGRESS: sort_entities_by_progress.bind(reversed),
		C.SORT.HEALTH: sort_entities_by_health.bind(reversed),
		C.SORT.DISTANCE: sort_entities_by_distance.bind(origin, reversed),
		C.SORT.MELEE_DAMAGE: sort_entities_by_melee_damage.bind(reversed),
		C.SORT.RANGE_DAMAGE: sort_entities_by_range_damage.bind(reversed),
		C.SORT.ID: sort_entities_by_id.bind(reversed),
	}
	
	if sort_type in sort_functions:
		entities_array.sort_custom(sort_functions[sort_type])


## 搜索范围内目标, 
## filter 匿名函数格式为 func(e: Entity) -> bool,
## 并返回 bool 表示是否被过滤
func find_targets_in_range(
		origin: Vector2,
		max_range: float,
		min_range: float = 0,
		flags: int = 0,
		bans: int = 0,
		filter: Callable = Callable(),
		group: String = ""
	) -> Array:
	
	var group_entities: Array = get_entities_group(group) if group else _entities
	
	return group_entities.filter(
		func(e) -> bool: return (
			U.is_vaild_entity(e)
			and not (bans & e.flag_bits or e.ban_bits & flags)
			and (
				not U.is_valid_number(max_range) 
				or U.is_in_radius(e.global_position, origin, max_range)
			)
			and not U.is_in_radius(e.global_position, origin, min_range)
			and (not filter.is_valid() or filter.call(e))
		)
	)


## 搜索并排序范围内目标, 
## filter 匿名函数格式为 func(e: Entity) -> bool,
## 并返回 bool 表示是否被过滤
func find_sorted_targets(
		sort_type: C.SORT,
		origin: Vector2,
		max_range: float,
		min_range: float = 0,
		flags: int = 0,
		bans: int = 0,
		filter: Callable = Callable(),
		group: String = "",
		reversed: bool = false
	) -> Array:
	var targets: Array = find_targets_in_range(
		origin, max_range, min_range, flags, bans, filter, group
	)
	sort_entities_by_type(targets, sort_type, origin, reversed)
	return targets


## 搜索范围内相应值最大的目标, 
## filter 匿名函数格式为 func(e: Entity) -> bool,
## 并返回 bool 表示是否被过滤
func find_extreme_target(
		sort_type: C.SORT,
		origin: Vector2,
		max_range: float,
		min_range: float = 0,
		flags: int = 0,
		bans: int = 0,
		filter: Callable = Callable(),
		group: String = "",
		reversed: bool = false
	) -> Entity:
	var targets: Array = find_targets_in_range(
		origin, max_range, min_range, flags, bans, filter, group
	)
	sort_entities_by_type(targets, sort_type, origin, reversed)
	return targets[0] if targets else null


## 搜索模式配置常量
const SEARCH_CONFIG: Dictionary[C.SEARCH, Array] = {
	# [sort_type, group, reversed]
	C.SEARCH.ENTITY_MAX_PROGRESS: [C.SORT.PROGRESS, "", false],
	C.SEARCH.ENTITY_MIN_PROGRESS: [C.SORT.PROGRESS, "", true],
	C.SEARCH.ENTITY_MAX_DISTANCE: [C.SORT.DISTANCE, "", false],
	C.SEARCH.ENTITY_MIN_DISTANCE: [C.SORT.DISTANCE, "", true],
	C.SEARCH.ENTITY_MAX_HEALTH: [C.SORT.HEALTH, "", false],
	C.SEARCH.ENTITY_MIN_HEALTH: [C.SORT.HEALTH, "", true],
	C.SEARCH.ENTITY_MAX_MELEE_DAMAGE: [C.SORT.MELEE_DAMAGE, "", false],
	C.SEARCH.ENTITY_MIN_MELEE_DAMAGE: [C.SORT.MELEE_DAMAGE, "", true],
	C.SEARCH.ENTITY_MAX_RANGE_DAMAGE: [C.SORT.RANGE_DAMAGE, "", false],
	C.SEARCH.ENTITY_MIN_RANGE_DAMAGE: [C.SORT.RANGE_DAMAGE, "", true],
	C.SEARCH.ENTITY_MAX_ID: [C.SORT.ID, "", false],
	C.SEARCH.ENTITY_MIN_ID: [C.SORT.ID, "", true],

	C.SEARCH.ENEMY_MAX_PROGRESS: [C.SORT.PROGRESS, C.GROUP_ENEMIES, false],
	C.SEARCH.ENEMY_MIN_PROGRESS: [C.SORT.PROGRESS, C.GROUP_ENEMIES, true],
	C.SEARCH.ENEMY_MAX_DISTANCE: [C.SORT.DISTANCE, C.GROUP_ENEMIES, false],
	C.SEARCH.ENEMY_MIN_DISTANCE: [C.SORT.DISTANCE, C.GROUP_ENEMIES, true],
	C.SEARCH.ENEMY_MAX_HEALTH: [C.SORT.HEALTH, C.GROUP_ENEMIES, false],
	C.SEARCH.ENEMY_MIN_HEALTH: [C.SORT.HEALTH, C.GROUP_ENEMIES, true],
	C.SEARCH.ENEMY_MAX_MELEE_DAMAGE: [C.SORT.MELEE_DAMAGE, C.GROUP_ENEMIES, false],
	C.SEARCH.ENEMY_MIN_MELEE_DAMAGE: [C.SORT.MELEE_DAMAGE, C.GROUP_ENEMIES, true],
	C.SEARCH.ENEMY_MAX_RANGE_DAMAGE: [C.SORT.RANGE_DAMAGE, C.GROUP_ENEMIES, false],
	C.SEARCH.ENEMY_MIN_RANGE_DAMAGE: [C.SORT.RANGE_DAMAGE, C.GROUP_ENEMIES, true],
	C.SEARCH.ENEMY_MAX_ID: [C.SORT.ID, C.GROUP_ENEMIES, false],
	C.SEARCH.ENEMY_MIN_ID: [C.SORT.ID, C.GROUP_ENEMIES, true],
	
	C.SEARCH.FRIENDLY_MAX_PROGRESS: [C.SORT.PROGRESS, C.GROUP_FRIENDLYS, false],
	C.SEARCH.FRIENDLY_MIN_PROGRESS: [C.SORT.PROGRESS, C.GROUP_FRIENDLYS, true],
	C.SEARCH.FRIENDLY_MAX_DISTANCE: [C.SORT.DISTANCE, C.GROUP_FRIENDLYS, false],
	C.SEARCH.FRIENDLY_MIN_DISTANCE: [C.SORT.DISTANCE, C.GROUP_FRIENDLYS, true],
	C.SEARCH.FRIENDLY_MAX_HEALTH: [C.SORT.HEALTH, C.GROUP_FRIENDLYS, false],
	C.SEARCH.FRIENDLY_MIN_HEALTH: [C.SORT.HEALTH, C.GROUP_FRIENDLYS, true],
	C.SEARCH.FRIENDLY_MAX_MELEE_DAMAGE: [C.SORT.MELEE_DAMAGE, C.GROUP_FRIENDLYS, false],
	C.SEARCH.FRIENDLY_MIN_MELEE_DAMAGE: [C.SORT.MELEE_DAMAGE, C.GROUP_FRIENDLYS, true],
	C.SEARCH.FRIENDLY_MAX_RANGE_DAMAGE: [C.SORT.RANGE_DAMAGE, C.GROUP_FRIENDLYS, false],
	C.SEARCH.FRIENDLY_MIN_RANGE_DAMAGE: [C.SORT.RANGE_DAMAGE, C.GROUP_FRIENDLYS, true],
	C.SEARCH.FRIENDLY_MAX_ID: [C.SORT.ID, C.GROUP_FRIENDLYS, false],
	C.SEARCH.FRIENDLY_MIN_ID: [C.SORT.ID, C.GROUP_FRIENDLYS, true],

	C.SEARCH.UNIT_MAX_PROGRESS: [C.SORT.PROGRESS, C.GROUP_UNIT, false],
	C.SEARCH.UNIT_MIN_PROGRESS: [C.SORT.PROGRESS, C.GROUP_UNIT, true],
	C.SEARCH.UNIT_MAX_DISTANCE: [C.SORT.DISTANCE, C.GROUP_UNIT, false],
	C.SEARCH.UNIT_MIN_DISTANCE: [C.SORT.DISTANCE, C.GROUP_UNIT, true],
	C.SEARCH.UNIT_MAX_HEALTH: [C.SORT.HEALTH, C.GROUP_UNIT, false],
	C.SEARCH.UNIT_MIN_HEALTH: [C.SORT.HEALTH, C.GROUP_UNIT, true],
	C.SEARCH.UNIT_MAX_MELEE_DAMAGE: [C.SORT.MELEE_DAMAGE, C.GROUP_UNIT, false],
	C.SEARCH.UNIT_MIN_MELEE_DAMAGE: [C.SORT.MELEE_DAMAGE, C.GROUP_UNIT, true],
	C.SEARCH.UNIT_MAX_RANGE_DAMAGE: [C.SORT.RANGE_DAMAGE, C.GROUP_UNIT, false],
	C.SEARCH.UNIT_MIN_RANGE_DAMAGE: [C.SORT.RANGE_DAMAGE, C.GROUP_UNIT, true],
	C.SEARCH.UNIT_MAX_ID: [C.SORT.ID, C.GROUP_UNIT, false],
	C.SEARCH.UNIT_MIN_ID: [C.SORT.ID, C.GROUP_UNIT, true],
}


## 根据搜索模式选择相应索敌函数（搜索范围内单个目标）,
## filter 匿名函数格式为 func(e: Entity) -> bool,
## 并返回 bool 表示是否被过滤
func search_target(
		search_mode: int, 
		origin: Vector2, 
		max_range: float, 
		min_range: float = 0, 
		flags: int = 0, 
		bans: int = 0, 
		filter: Callable = Callable()
	) -> Entity:
	if search_mode not in SEARCH_CONFIG:
		Log.error("未知搜索模式: %s" % search_mode)
		return null
		
	var config: Array = SEARCH_CONFIG[search_mode]
	return find_extreme_target(
		config[0], origin, max_range, min_range, 
		flags, bans, filter, config[1], config[2]
	)


## 根据搜索模式选择相应索敌函数（搜索范围内所有目标）,
## filter 匿名函数格式为 func(e: Entity) -> bool,
## 并返回 bool 表示是否被过滤
func search_targets_in_range(
		search_mode: int, 
		origin: Vector2, 
		max_range: float, 
		min_range: float = 0, 
		flags: int = 0, 
		bans: int = 0, 
		filter: Callable = Callable()
	) -> Array:
	if search_mode not in SEARCH_CONFIG:
		Log.error("未知搜索模式: %s" % search_mode)
		return []
		
	var config: Array = SEARCH_CONFIG[search_mode]
	return find_sorted_targets(
		config[0], origin, max_range, min_range, 
		flags, bans, filter, config[1], config[2]
	)
#endregion
