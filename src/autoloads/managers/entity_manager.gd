extends Node
## 实体管理器。
##
## [EntityManager] 负责管理实体，提供了实体的查找、插入、移除等操作。


@warning_ignore_start("unused_signal")
## 实体创建信号。
signal entity_created(entity: Entity)
## 实体准备信号。
signal entity_ready(entity: Entity)
## 实体设置信号。
signal entity_setup(entity: Entity)
@warning_ignore_restore("unused_signal")


## 实体场景缓存。
var _entity_scene_caches: Dictionary[String, PackedScene] = {}
## 实体世界。
var _entity_world: EntityWorld = null
## 实体插入队列。
var _insert_queue: Array[Entity] = []
## 实体移除队列。
var _remove_queue: Array[Entity] = []
## 下一个创建实体的 id。
var _next_id: int = 0
## 所有实体数组，无效的实体为 [null]。
var _entities: Array[Entity] = []
## 所有有效实体数组，用于在 [System] 中快速查找所有有效实体。
var _valid_entities: Array[Entity] = []
## 按组件类型索引的实体组数组，用于在 [System] 中快速查找相应组件的实体。
var _component_entity_groups: Array[Array] = []
## 实体类型组字典，用于在 [Searcher] 中快速查找相应实体类型的实体。
var _entity_groups: Dictionary[int, Array] = {}


func _physics_process(_delta: float) -> void:
	_process_insert_queue()
	_process_remove_queue()
	_grouping_entities()


## 初始化实体管理器。
func init() -> void:
	for faction: InteractPolicyComponent.Faction in InteractPolicyComponent.Faction.values():
		var shifted_faction: int = faction << Constants.INT64_LEN_HALF
		for entity_type: InteractPolicyComponent.EntityType in InteractPolicyComponent.EntityType.values():
			var entity_group: Array[Entity] = []
			_entity_groups[shifted_faction | entity_type] = entity_group

	_component_entity_groups.resize(Enums.ComponentFlag.size())
	for component_flag: Enums.ComponentFlag in Enums.ComponentFlag.values():
		var entity_group: Array[Entity] = []
		_component_entity_groups[component_flag] = entity_group


## 清理实体管理器，这通常用于清除实体管理器中的所有引用。
func cleanup() -> void:
	_entity_scene_caches.clear()
	_entity_world = null
	_remove_queue.clear()
	_insert_queue.clear()
	_next_id = 0
	_entities.clear()
	_valid_entities.clear()
	_entity_groups.clear()
	_component_entity_groups.clear()


## 注册实体世界。
func register_entity_world(entity_world: EntityWorld) -> void:
	_entity_world = entity_world


## 将实体增加到插入队列
func queue_insert_entity(entity: Entity) -> void:
	entity.visible = false
	_insert_queue.append(entity)
	Log.verbose("增加实体到插入队列: %s" % entity)


## 将实体增加到移除队列
func queue_remove_entity(entity: Entity) -> void:
	_remove_queue.append(entity)
	Log.verbose("增加实体到移除队列: %s" % entity)


## 通过场景路径创建实体。
func create_entity(entity_scene_path: String) -> Entity:
	var scene: PackedScene = load(entity_scene_path)
	var entity: Entity = scene.instantiate()
	_entity_scene_caches[entity_scene_path] = scene

	entity_created.emit(entity)
		
	return setup_entity(entity)
	
	
## 设置实体，处理实体创建后续操作。
func setup_entity(entity: Entity) -> Entity:
	entity.id = _next_id
	entity.name = "%sI%d" % [entity.name, _next_id]

	Log.debug("创建实体: %s" % entity)
	_next_id += 1

	entity_ready.emit(entity)
	SystemManager.process_entity_ready(entity)
	
	if not entity.get_parent():
		_entity_world.add_child(entity)

	entity_setup.emit(entity)

	return entity


## 批量创建实体。
func create_entities(
		entity_scenes: PackedStringArray,
		config_func := Callable(),
		auto_insert: bool = true
	) -> Array[Entity]:
	var created_entities: Array[Entity] = []
	
	for entity_scene: String in entity_scenes:
		var entity: Entity = create_entity(entity_scene)
		
		if config_func.is_valid():
			config_func.call(entity)
		
		if auto_insert:
			queue_insert_entity(entity)
		
		created_entities.append(entity)
	
	return created_entities


## 在全局位置处创建实体。
func create_entities_at_global_position(
		entity_scenes: PackedStringArray, 
		create_position: Vector2, 
		auto_insert: bool = true 
	) -> Array[Entity]:
	var config_func: Callable = func(entity: Entity) -> void: 
		entity.set_global_position_with_components(create_position)

	return create_entities(
		entity_scenes, config_func, auto_insert
	)


## 批量创建修改器实体。
func create_modifiers(
		target_id: int,
		entity_scenes: PackedStringArray, 
		source_id: int = Constants.UNSET,
		auto_insert: bool = true
	) -> Array[Entity]:
	var config_func: Callable = func(entity: Entity) -> void:
		entity.source_id = source_id

		var modifier_c: ModifierComponent = entity.get_node_or_null(Constants.MODIFIER_COMPONENT_NODE_PATH)
		modifier_c.target_id = target_id

	return create_entities(
		entity_scenes, 
		config_func,
		auto_insert
	)


## 批量创建光环实体。
func create_auras(
		target_id: int,
		entity_scenes: PackedStringArray, 
		source_id: int = Constants.UNSET,
		auto_insert: bool = true
	) -> Array[Entity]:
	var config_func: Callable = func(entity: Entity) -> void:
		entity.source_id = source_id

		var aura_c: AuraComponent = entity.get_node_or_null(Constants.AURA_COMPONENT_NODE_PATH)
		aura_c.target_id = target_id
		
	return create_entities(
		entity_scenes, 
		config_func,
		auto_insert
	)


## 获取所有有效实体数组，不包含已被移除的实体。
func get_valid_entities() -> Array[Entity]:
	return _valid_entities


## 获取实体组。
func get_entity_group(faction: InteractPolicyComponent.Faction, entity_type: InteractPolicyComponent.EntityType) -> Array[Entity]:
	var group_key: int = faction << Constants.INT64_LEN_HALF | entity_type
	return _entity_groups[group_key]


## 获取按组件类型索引的实体组。
func get_component_entity_group(component_flag: Enums.ComponentFlag) -> Array[Entity]:
	return _component_entity_groups[component_flag]


## 根据 id 获取实体。
func get_entity_by_id(entity_id: int) -> Entity:
	if entity_id == Constants.UNSET:
		return null

	var entity: Entity = _entities.get(entity_id)
	if not entity:
		return null

	return entity


## 处理实体插入队列。
func _process_insert_queue() -> void:
	var head_index: int = 0
	while head_index < _insert_queue.size():
		var entity: Entity = _insert_queue[head_index]
		_insert_queue[head_index] = null
		head_index += 1
	
		# if _entities:
		# 	var entities_len: int = _entities.size()
		# 	if entity.id != entities_len:
		# 		Log.error(
		# 			"实体数组长度未与实体 id 对应: id %d, 长度 %d" 
		# 			% [entity.id, entities_len]
		# 		)
		
		if not SystemManager.process_entity_insert(entity):
			continue

		_entities.append(entity)

		entity.visible = true
		Log.verbose("插入实体: %s" % entity)

	_insert_queue.clear()


## 处理实体移除队列。
func _process_remove_queue() -> void:
	var pending_free_entities: Array[Entity] = []
	var head_index: int = 0
	while head_index < _remove_queue.size():
		var entity: Entity = _remove_queue[head_index]
		_remove_queue[head_index] = null
		head_index += 1
		
		if not SystemManager.process_entity_remove(entity):
			entity.visible = true
			continue

		_entities[entity.id] = null

		# 先处理所有移除回调，再释放实体
		pending_free_entities.append(entity)
		entity.entity_removing.emit()
		Log.verbose("移除实体: %s" % entity)

	_remove_queue.clear()
	for entity: Entity in pending_free_entities:
		entity.free()


## 分组实体。
func _grouping_entities() -> void:
	_valid_entities.clear()
		
	for group: Array[Entity] in _component_entity_groups:
		group.clear()

	for entity: Entity in _entities:
		if not entity:
			continue
		
		_valid_entities.append(entity)
		
		for child: Node in entity.get_children():
			if not child is Component:
				continue

			var script: GDScript = child.get_script()
			var component_class_name: StringName = script.get_global_name()
			var component_flag: Enums.ComponentFlag = Constants.COMPONENT_NAME_TO_FLAG[component_class_name]
			_component_entity_groups[component_flag].append(entity)
		
		var interact_policy_c: InteractPolicyComponent = entity.get_node_or_null(Constants.INTERACT_POLICY_COMPONENT_NODE_PATH)
		if not interact_policy_c:
			continue
		
		var interact_policy_c_config: InteractPolicyComponentNodeConfig = interact_policy_c.config
		var interact_policy_c_config_entity_type: InteractPolicyComponent.EntityType = interact_policy_c_config.entity_type
		for entity_type: InteractPolicyComponent.EntityType in InteractPolicyComponent.EntityType.values():
			if not entity_type & interact_policy_c_config_entity_type:
				continue

			var group_key: int = interact_policy_c_config.faction << Constants.INT64_LEN_HALF | entity_type
			_entity_groups[group_key].append(entity)
