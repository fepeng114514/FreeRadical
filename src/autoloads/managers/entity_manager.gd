extends Node
## 实体管理器。
##
## 负责管理实体，提供了实体的基础查找、插入、移除等操作。


@warning_ignore_start("unused_signal")
## 实体创建信号。
signal entity_created(entity: Entity)
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
## 插入队列头索引。
var _insert_queue_head_index: int = 0
## 插入队列压缩阈值。
var _insert_queue_compress_threshold: int = 64
## 实体移除队列。
var _remove_queue: Array[Entity] = []
## 移除队列头索引。
var _remove_queue_head_index: int = 0
## 移除队列压缩阈值。
var _remove_queue_compress_threshold: int = 64
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
	SystemManager.process_update(delta)


## 初始化实体管理器。
func init() -> void:
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
	
	if not entity.get_parent():
		_entity_world.add_child(entity)

	entity_setup.emit(entity)

	return entity


## 批量创建实体。
func create_entities(
		entity_scenes: PackedStringArray,
		config_func: Callable = Callable(),
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
	return create_entities(
		entity_scenes, func(entity): entity.set_global_position_with_components(create_position), auto_insert
	)


## 批量创建修改器实体。
func create_mods(
		target_id: int,
		entity_scenes: PackedStringArray, 
		source_id: int = Constants.UNSET,
		auto_insert: bool = true
	) -> Array[Entity]:
	return create_entities(
		entity_scenes, 
		func(entity):
		entity.target_id = target_id
		entity.source_id = source_id
		, 
		auto_insert
	)


## 批量创建光环实体。
func create_auras(
		target_id: int,
		entity_scenes: PackedStringArray, 
		source_id: int = Constants.UNSET,
		auto_insert: bool = true
	) -> Array[Entity]:
	return create_entities(
		entity_scenes, 
		func(entity):
		entity.target_id = target_id
		entity.source_id = source_id
		, 
		auto_insert
	)


## 获取所有有效实体数组，不包含已被移除的实体。
func get_valid_entities() -> Array[Entity]:
	return _valid_entities


## 根据组名获取实体组。
func get_entity_group(group_name: String) -> Array[Entity]:
	if not _entity_groups.has(group_name):
		return []

	return _entity_groups[group_name].entities


## 获取按组件类型索引的实体组。
func get_component_entity_group(group_name: String) -> Array[Entity]:
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


## 搜索椭圆环范围内目标。[br][br]
## [param filter]: 过滤函数。返回 [code]false[/code] 表示被过滤。
func search_entities_in_ellipse(
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
					
				if filter.is_valid() and not filter.call(entity):
					continue
					
				entities.append(entity)

	return entities


## 搜索圆环范围内目标。[br][br]
## [param filter]: 过滤函数。返回 [code]false[/code] 表示被过滤。
func search_entities_in_circle(
		search_global_position: Vector2,
		min_range: float,
		max_range: float,
		filter := Callable(),
		searched_group: StringName = &""
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
				if not MathUtils.is_in_ring(search_global_position, entity.global_position, min_range, max_range):
					continue
					
				if filter.is_valid() and not filter.call(entity):
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
	while _insert_queue:
		var entity: Entity = _insert_queue[_insert_queue_head_index]
		_insert_queue[_insert_queue_head_index] = null
		_insert_queue_head_index += 1
		
		if _insert_queue_head_index > _insert_queue_compress_threshold and _insert_queue_head_index * 2 >= _insert_queue.size():
			_insert_queue = _insert_queue.slice(_insert_queue_head_index)
			_insert_queue_head_index = 0
	
		# if _entities:
		# 	var entities_len: int = _entities.size()
		# 	if entity.id != entities_len:
		# 		Log.error(
		# 			"实体数组长度未与实体 id 对应: id %d, 长度 %d" 
		# 			% [entity.id, entities_len]
		# 		)
		
		if not SystemManager.process_entity_insert(entity):
			continue

		entity.tree_exiting.connect(_on_entity_tree_exiting.bind(entity))

		_entities.append(entity)
		entity.valid_entities_index = _valid_entities.size()
		_valid_entities.append(entity)

		var cell_index: int = global_position_to_spatial_hash_cell_index(entity.global_position)
		var cell: SpaceIndexCell = get_spatial_hash_cell(cell_index)
		if cell:
			var cell_entities: Array[Entity] = cell.entities
			entity.space_hash_cell_entities_index = cell_entities.size()
			cell_entities.append(entity)
		
		for group_name: StringName in entity.entity_groups:
			var group: EntityGroup = _entity_groups.get_or_add(
				group_name, EntityGroup.new()
			)
			var group_entities: Array[Entity] = group.entities
			entity.entity_groups_indexes[group_name] = group_entities.size()
			group_entities.append(entity)

			if not cell:
				continue
				
			var cell_group: EntityGroup = cell.entity_groups.get_or_add(
				group_name, EntityGroup.new()
			)
			var cell_group_entities: Array[Entity] = cell_group.entities
			entity.space_hash_cell_entity_groups_indexes[group_name] = cell_group_entities.size()
			cell_group_entities.append(entity)

		for component_name: StringName in entity.components:
			var component_group: EntityGroup = _component_entity_groups.get_or_add(
				component_name, EntityGroup.new()
			)
			var component_group_entities: Array[Entity] = component_group.entities
			entity.component_entity_groups_indexes[component_name] = component_group_entities.size()
			component_group_entities.append(entity)

			if not cell:
				continue
				
			var cell_component_group: EntityGroup = cell.component_entity_groups.get_or_add(
				component_name, EntityGroup.new()
			)
			var cell_component_group_entities: Array[Entity] = cell_component_group.entities
			entity.space_hash_cell_component_entity_groups_indexes[component_name] = cell_component_group_entities.size()
			cell_component_group_entities.append(entity)
		
		entity.visible = true
		Log.verbose("插入实体: %s" % entity)


## 处理实体移除队列。
func _process_remove_queue() -> void:
	while _remove_queue:
		var entity: Entity = _remove_queue[_remove_queue_head_index]
		_remove_queue[_remove_queue_head_index] = null
		_remove_queue_head_index += 1
		
		if _remove_queue_head_index > _remove_queue_compress_threshold and _remove_queue_head_index * 2 >= _remove_queue.size():
			_remove_queue = _remove_queue.slice(_remove_queue_head_index)
			_remove_queue_head_index = 0
		
		if not SystemManager.process_entity_remove(entity):
			entity.visible = true
			continue

		entity.free()
		Log.verbose("移除实体: %s" % entity)


## 分组实体。
func _grouping_entities() -> void:
	for entity: Entity in _entities:
		if not entity:
			continue

		var cell_index: int = global_position_to_spatial_hash_cell_index(entity.global_position)
		var last_space_hash_cell_index: int = entity.last_space_hash_cell_index
		if last_space_hash_cell_index != cell_index:
			var last_cell: SpaceIndexCell = get_spatial_hash_cell(last_space_hash_cell_index)
			var cell: SpaceIndexCell = get_spatial_hash_cell(cell_index)

			if entity.is_entity_groups_changed:
				_remove_and_append_groups_entity_with_diff(
					entity,
					entity.last_entity_groups,
					entity.entity_groups,
					entity.last_space_hash_cell_entity_groups_indexes,
					entity.space_hash_cell_entity_groups_indexes,
					last_cell.entity_groups if last_cell else {},
					cell.entity_groups if cell else {}
				)
			if entity.is_component_changed:
				_remove_and_append_groups_entity_with_diff(
					entity,
					entity.last_component_names,
					entity.component_names,
					entity.last_space_hash_cell_component_entity_groups_indexes,
					entity.space_hash_cell_component_entity_groups_indexes,
					last_cell.component_entity_groups if last_cell else {},
					cell.component_entity_groups if cell else {}
				)
			entity.last_space_hash_cell_index = cell_index

		if entity.is_entity_groups_changed:
			entity.is_entity_groups_changed = false
			_remove_and_append_groups_entity_with_diff(
				entity,
				entity.last_entity_groups,
				entity.entity_groups,
				entity.last_entity_groups_indexes,
				entity.entity_groups_indexes,
				_entity_groups,
				_entity_groups
			)

		if entity.is_component_changed:
			entity.is_component_changed = false
			_remove_and_append_groups_entity_with_diff(
				entity,
				entity.last_component_names,
				entity.component_names,
				entity.last_component_entity_groups_indexes,
				entity.component_entity_groups_indexes,
				_component_entity_groups,
				_entity_groups
			)


func _remove_and_append_groups_entity_with_diff(
		entity: Entity,
		last_group_names: Array[StringName],
		group_names: Array[StringName],
		last_entity_groups_indexes: Dictionary[StringName, int],
		entity_groups_indexes: Dictionary[StringName, int],
		removed_groups: Dictionary[StringName, EntityGroup],
		appended_groups: Dictionary[StringName, EntityGroup]
	) -> void:
	var counts: Dictionary[StringName, int] = {}
	var last_has_group_names: Dictionary[StringName, bool] = {}
	var new_has_group_names: Dictionary[StringName, bool] = {}

	for group_name: StringName in last_group_names:
		counts[group_name] = counts.get(group_name, 0) + 1
		last_has_group_names[group_name] = true

	for group_name: StringName in group_names:
		counts[group_name] = counts.get(group_name, 0) + 1
		new_has_group_names[group_name] = true

	last_entity_groups_indexes.clear()

	for group_name: StringName in counts:
		if counts[group_name] > 1:
			continue

		if last_has_group_names.has(group_name):
			var group: EntityGroup = removed_groups[group_name]
			ArrayUtils.array_swap_delete(group.entities, last_entity_groups_indexes[group_name])
		else:
			var group: EntityGroup = appended_groups.get_or_add(group_name, EntityGroup.new())
			var group_entities: Array[Entity] = group.entities

			last_entity_groups_indexes[group_name] = entity_groups_indexes[group_name]
			entity_groups_indexes[group_name] = group_entities.size()
			group_entities.append(entity)


func _on_entity_tree_exiting(entity: Entity) -> void:
	_entities[entity.id] = null
		
	ArrayUtils.array_swap_delete(_valid_entities, entity.valid_entities_index)

	var cell_index: int = global_position_to_spatial_hash_cell_index(entity.global_position)
	var cell: SpaceIndexCell = get_spatial_hash_cell(cell_index)
	if cell:
		ArrayUtils.array_swap_delete(
			cell.entities, entity.space_hash_cell_entities_index
		)
		
	for group_name: StringName in entity.entity_groups:
		var group: EntityGroup = _entity_groups[group_name]
		ArrayUtils.array_swap_delete(
			group.entities,
			entity.entity_groups_indexes[group_name]
		)
		
		if not cell:
			continue
				
		var cell_group: EntityGroup = cell.entity_groups[group_name]
		ArrayUtils.array_swap_delete(
			cell_group.entities,
			entity.space_hash_cell_entity_groups_indexes[group_name]
		)

	for component_name: StringName in entity.components:
		var component_group: EntityGroup = _component_entity_groups[component_name]
		ArrayUtils.array_swap_delete(
			component_group.entities,
			entity.component_entity_groups_indexes[component_name]
		)
		
		if not cell:
			continue
				
		var cell_component_group: EntityGroup = cell.component_entity_groups[component_name]
		ArrayUtils.array_swap_delete(
			cell_component_group.entities,
			entity.space_hash_cell_component_entity_groups_indexes[component_name]
		)
		

class EntityGroup extends RefCounted:
	## 实体组内的实体。
	var entities: Array[Entity] = []


## 空间哈希网格单元。
class SpaceIndexCell extends RefCounted:
	## 网格内的实体。
	var entities: Array[Entity] = []
	## 网格内的实体组。
	var entity_groups: Dictionary[StringName, EntityGroup] = {}
	## 网格内的组件实体组。
	var component_entity_groups: Dictionary[StringName, EntityGroup] = {}

	func remove_entity(entity: Entity) -> void:
		ArrayUtils.array_swap_delete(entities, entity.entities_index)
		entity.entities_index = -1
