extends Node
## 实体管理器。
##
## 负责管理实体与相关操作。


## 所有实体数组。
var entity_list: Array = []
## 存储实体类型组的字典。
var type_group_list: Dictionary[String, Array] = {
	C.GROUP_ENEMY: [],
	C.GROUP_FRIENDLY: [],
	C.GROUP_UNIT: [],
	C.GROUP_TOWER: [],
}
## 存储组件组的字典。
var component_group_list: Dictionary[String, Array] = {}
## 存储实体场景的字典。
var _entity_scene_dict: Dictionary[String, PackedScene] = {}
## 下一个创建实体的 id。
var _next_id: int = 0
## 实体数据缓存字典，用于读取数据，不参与游戏。
var _cached_entities_data: Dictionary[PackedScene, Entity] = {}


func _clear() -> void:
	_entity_scene_dict.clear()
	_cached_entities_data.clear()
	component_group_list.clear()
	entity_list.clear()

	for group: Array in type_group_list.values():
		group.clear()

	_next_id = 0


#region 创建实体相关
## 通过场景名创建实体。
func create_entity(entity_scene: PackedScene) -> Entity:
	var e: Entity = entity_scene.instantiate()
		
	return setup_entity(e)
	
	
## 设置实体，处理实体创建后续操作。
func setup_entity(e: Entity) -> Entity:
	e.id = _next_id
	e.name = "%sI%d" % [e.name, _next_id]

	Log.debug("创建实体: %s" % e)
	_next_id += 1
		
	return e


## 批量创建实体。
func create_entities(
		scene_list: Array[PackedScene],	
		config_func: Callable = Callable(),
		auto_insert: bool = true
	) -> Array[Entity]:
	
	var created_entities: Array[Entity] = []
	
	for scene: PackedScene in scene_list:
		var e: Entity = create_entity(scene)
		
		if config_func.is_valid():
			config_func.call(e)
		
		if auto_insert:
			e.insert_entity()
		
		created_entities.append(e)
	
	return created_entities


## 创建实体在指定位置。
func create_entities_at_pos(
		scene_list: Array[PackedScene], 
		pos: Vector2, 
		auto_insert: bool = true 
	) -> Array[Entity]:
	return create_entities(
		scene_list, func(e): e.set_pos(pos), auto_insert
	)


## 批量创建状态效果实体。
func create_mods(
		target_id: int,
		scene_list: Array[PackedScene], 
		source_id: int = C.UNSET,
		auto_insert: bool = true
	) -> Array[Entity]:
	
	return create_entities(
		scene_list, 
		func(e):
		e.target_id = target_id
		e.source_id = source_id
		, 
		auto_insert
	)


## 批量创建光环实体。
func create_auras(
		target_id: int,
		scene_list: Array[PackedScene], 
		source_id: int = C.UNSET,
		auto_insert: bool = true
	) -> Array[Entity]:
	
	return create_entities(
		scene_list, 
		func(e):
		e.target_id = target_id
		e.source_id = source_id
		, 
		auto_insert
	)
#endregion


## 根据组名获取组内所有实体。
func get_entities_group_by_type(group_name: String) -> Array:
	if not type_group_list.has(group_name):
		return []

	return type_group_list[group_name]


## 根据组名获取组内所有实体。
func get_entities_group_by_component(group_name: String) -> Array:
	if not component_group_list.has(group_name):
		return []

	return component_group_list[group_name]


## 根据 id 获取实体。
func get_entity_by_id(id: int) -> Entity:
	if not U.is_valid_number(id):
		return null

	var e = entity_list.get(id)
	if not e:
		return null

	return e


## 获取所有有效实体。
func get_valid_entities() -> Array[Entity]:
	var valid_entities: Array[Entity] = []

	for e in entity_list:
		if not U.is_valid_entity(e):
			continue
		
		valid_entities.append(e)
	
	return valid_entities

	
## 获取实体数据，实体数据是一个实体实例，仅用于读取原始数据，不参与游戏逻辑。
func get_entity_data(entity_scene: PackedScene) -> Entity:
	if not _cached_entities_data.has(entity_scene) :
		var e: Entity = entity_scene.instantiate()
		_cached_entities_data[entity_scene] = e

	return _cached_entities_data[entity_scene]
