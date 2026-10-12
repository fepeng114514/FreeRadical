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


## 空间哈希的网格大小。
var _spatial_hash_cell_size: int = 100
## 空间哈希的网格行数。
var _spatial_hash_row_count: int = 26
## 空间哈希的网格列数。
var _spatial_hash_column_count: int = 15
## 空间哈希网格的总单元格数。
var _spatial_hash_cell_count: int

## 实体场景缓存。
var _entity_scene_caches: Dictionary[String, PackedScene] = {}
## 实体世界。
var _entity_world: EntityWorld = null
## 所有实体数组，无效的实体为 [null]。
var _entities: Array[Entity] = []
## 实体插入队列。
var _insert_queue: Array[Entity] = []
## 实体移除队列。
var _remove_queue: Array[Entity] = []
## 所有有效实体数组。
var _valid_entities: Array[Entity] = []
## 实体组字典。
var _entity_groups: Dictionary[StringName, EntityGroup] = {}
## 按组件类型索引的实体组字典。
var _component_entity_groups: Dictionary[StringName, EntityGroup] = {}
## 下一个创建实体的 id。
var _next_id: int = 0
## 空间哈希网格数组。
var _spatial_hash_grid: Array[SpaceIndexCell] = []


func _physics_process(delta: float) -> void:
	_process_insert_queue()
	_process_remove_queue()
	_grouping_entities()
	SystemManager.process_entity_update(delta)
	SystemManager.process_entity_first_update()


## 初始化实体管理器。
func init() -> void:
	for group_name: StringName in Constants.ALL_GROUPS:
		_entity_groups[group_name] = EntityGroup.new()

	for component_name: StringName in Constants.ALL_COMPONENT_NAMES:
		_component_entity_groups[component_name] = EntityGroup.new()

	_spatial_hash_cell_count = _spatial_hash_row_count * _spatial_hash_column_count
	_spatial_hash_grid.resize(_spatial_hash_cell_count)
	for i: int in _spatial_hash_cell_count:
		_spatial_hash_grid[i] = SpaceIndexCell.new()


## 清理实体管理器，这通常用于清除实体管理器中的所有引用。
func cleanup() -> void:
	_entity_scene_caches.clear()
	_entity_world = null
	_remove_queue.clear()
	_insert_queue.clear()
	_entities.clear()
	_valid_entities.clear()
	_entity_groups.clear()
	_component_entity_groups.clear()
	_spatial_hash_grid.clear()
	_next_id = 0


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
func create_mods(
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


## 根据组名获取实体组。
func get_entity_group(group_name: StringName) -> Array[Entity]:
	if not _entity_groups.has(group_name):
		return []

	return _entity_groups[group_name].entities


## 获取按组件类型索引的实体组。
func get_component_entity_group(group_name: StringName) -> Array[Entity]:
	if not _component_entity_groups.has(group_name):
		return []

	return _component_entity_groups[group_name].entities


## 根据 id 获取实体。
func get_entity_by_id(entity_id: int) -> Entity:
	if entity_id == -1:
		return null

	var entity: Entity = _entities.get(entity_id)
	if not entity:
		return null

	return entity


## 搜索椭圆环范围内目标。
func search_entities_in_ellipse(
		search_global_position: Vector2,
		min_range: float,
		max_range: float,
		searched_group: StringName = &"",
		aspect: float = 0.7
	) -> Array[Entity]:
	var entities: Array[Entity] = []

	var grid_min_x: int = max(0, floori((search_global_position.x - max_range) / _spatial_hash_cell_size))
	var grid_max_x: int = ceili((search_global_position.x + max_range) / _spatial_hash_cell_size)
	var grid_min_y: int = max(0, floori((search_global_position.y - max_range) / _spatial_hash_cell_size))
	var grid_max_y: int = ceili((search_global_position.y + max_range) / _spatial_hash_cell_size)

	for grid_x: int in range(grid_min_x, grid_max_x + 1):
		for grid_y: int in range(grid_min_y, grid_max_y + 1):
			var cell_index: int = grid_position_to_spatial_hash_cell_index(grid_x, grid_y)
			var cell: SpaceIndexCell = get_spatial_hash_cell(cell_index)
			if not cell:
				continue

			var iterative_entities: Array[Entity] = cell.entity_groups[searched_group].entities if searched_group else cell.entities
			for entity: Entity in iterative_entities:
				if not MathUtils.is_in_ellipse_ring(search_global_position, entity.global_position, min_range, max_range, aspect):
					continue
					
				entities.append(entity)

	return entities


## 搜索椭圆环范围内目标。[br][br]
## [param filter]: 过滤函数。返回 [code]false[/code] 表示被过滤。[br][br]
## 与 [method EntityManager.search_entities_in_ellipse] 不同的是，支持过滤函数。
func search_entities_in_ellipse_filtered(
		search_global_position: Vector2,
		min_range: float,
		max_range: float,
		filter := Callable(),
		searched_group: StringName = &"",
		aspect: float = 0.7
	) -> Array[Entity]:
	var entities: Array[Entity] = []

	var grid_min_x: int = max(0, floori((search_global_position.x - max_range) / _spatial_hash_cell_size))
	var grid_max_x: int = ceili((search_global_position.x + max_range) / _spatial_hash_cell_size)
	var grid_min_y: int = max(0, floori((search_global_position.y - max_range) / _spatial_hash_cell_size))
	var grid_max_y: int = ceili((search_global_position.y + max_range) / _spatial_hash_cell_size)

	for grid_x: int in range(grid_min_x, grid_max_x + 1):
		for grid_y: int in range(grid_min_y, grid_max_y + 1):
			var cell_index: int = grid_position_to_spatial_hash_cell_index(grid_x, grid_y)
			var cell: SpaceIndexCell = get_spatial_hash_cell(cell_index)
			if not cell:
				continue

			var iterative_entities: Array[Entity] = cell.entity_groups[searched_group].entities if searched_group else cell.entities
			for entity: Entity in iterative_entities:
				if not MathUtils.is_in_ellipse_ring(search_global_position, entity.global_position, min_range, max_range, aspect):
					continue
					
				if not filter.call(entity):
					continue
					
				entities.append(entity)

	return entities


## 全局位置转换空间哈希单元格索引。
func global_position_to_spatial_hash_cell_index(position: Vector2) -> int:
	var grid_x: int = floori(position.x / _spatial_hash_cell_size)
	var grid_y: int = floori(position.y / _spatial_hash_cell_size)

	return grid_position_to_spatial_hash_cell_index(grid_x, grid_y)


## 网格坐标转换空间哈希单元格索引。
func grid_position_to_spatial_hash_cell_index(x: int, y: int) -> int:
	return x * _spatial_hash_column_count + y


## 获取空间哈希单元格。如果单元格不存在则返回 [code]null[/code]。
func get_spatial_hash_cell(index: int) -> SpaceIndexCell:
	if index < 0 or index >= _spatial_hash_grid.size():
		return null

	return _spatial_hash_grid.get(index)


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
	var need_free_entities: Array[Entity] = []
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
		need_free_entities.append(entity)
		entity.entity_removing.emit()
		Log.verbose("移除实体: %s" % entity)

	_remove_queue.clear()
	for entity: Entity in need_free_entities:
		entity.free()


## 分组实体。
func _grouping_entities() -> void:
	_valid_entities.clear()

	for group_name: StringName in _entity_groups:
		_entity_groups[group_name].clear()
		
	for group_name: StringName in _component_entity_groups:
		_component_entity_groups[group_name].clear()

	for cell: SpaceIndexCell in _spatial_hash_grid:
		cell.clear()

	for entity: Entity in _entities:
		if not entity:
			continue
		
		_valid_entities.append(entity)
		
		for child: Node in entity.get_children():
			if not child is Component:
				continue

			var script: GDScript = child.get_script()
			var component_class_name: StringName = script.get_global_name()
			
			_component_entity_groups[component_class_name].append(entity)

		var cell_index: int = global_position_to_spatial_hash_cell_index(entity.global_position)
		var cell: SpaceIndexCell = get_spatial_hash_cell(cell_index)
		if cell:
			cell.entities.append(entity)

		var entity_c: EntityComponent = entity.get_node_or_null(Constants.ENTITY_COMPONENT_NODE_PATH)
		if not entity_c:
			continue
		
		var flags: int = entity_c.config.interact_policy.flags
		if flags & InteractPolicy.Flag.ENEMY:
			_append_entity_to_entity_group(entity, Constants.GROUP_ENEMIES, cell)
		if flags & InteractPolicy.Flag.FRIENDLY:
			_append_entity_to_entity_group(entity, Constants.GROUP_FRIENDLIES, cell)
		if flags & InteractPolicy.Flag.UNIT:
			_append_entity_to_entity_group(entity, Constants.GROUP_UNITS, cell)
		if flags & InteractPolicy.Flag.TOWER:
			_append_entity_to_entity_group(entity, Constants.GROUP_TOWERS, cell)


## 将实体添加到实体组。
func _append_entity_to_entity_group(entity: Entity, group_name: StringName, cell: SpaceIndexCell) -> void:
	_entity_groups[group_name].append(entity)
	if not cell:
		return

	cell.entity_groups[group_name].append(entity)


class EntityGroup extends RefCounted:
	## 实体组内的实体。
	var entities: Array[Entity] = []

	func append(entity: Entity) -> void:
		entities.append(entity)

	func clear() -> void:
		entities.clear()


## 空间哈希网格单元。
class SpaceIndexCell extends RefCounted:
	## 网格内的实体。
	var entities: Array[Entity] = []
	## 网格内的实体组。
	var entity_groups: Dictionary[StringName, EntityGroup] = {}

	func _init() -> void:
		for group_name: StringName in Constants.ALL_GROUPS:
			entity_groups[group_name] = EntityGroup.new()

	func clear() -> void:
		entities.clear()

		for group_name: StringName in entity_groups:
			entity_groups[group_name].clear()
