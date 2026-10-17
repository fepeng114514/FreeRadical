extends Node
## 实体空间哈希管理器。
##
## [EntitySpatialHashManager] 用于通过实体坐标快速查找实体。


## 空间哈希的网格大小。
var _spatial_hash_cell_size: int = 100
## 空间哈希的网格行数。
var _spatial_hash_row_count: int = 26
## 空间哈希的网格列数。
var _spatial_hash_column_count: int = 15


## 空间哈希网格数组。
var spatial_hash_grid: Array[SpaceIndexCell] = []


func _physics_process(_delta: float) -> void:
	_grouping_entities()


## 初始化实体管理器。
func init() -> void:
	var spatial_hash_cell_count: int = _spatial_hash_row_count * _spatial_hash_column_count
	spatial_hash_grid.resize(spatial_hash_cell_count)
	for i: int in spatial_hash_cell_count:
		spatial_hash_grid[i] = SpaceIndexCell.new()


## 清理实体空间哈希管理器，这通常用于清除实体空间哈希管理器中的所有引用。
func cleanup() -> void:
	spatial_hash_grid.clear()


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
	if index < 0 or index >= spatial_hash_grid.size():
		return null

	return spatial_hash_grid.get(index)


## 通过空间哈希网格搜索椭圆环范围内目标。
func search_entities_in_ellipse(
		search_global_position: Vector2,
		min_range: float,
		max_range: float,
		faction: InteractPolicyComponent.Faction,
		entity_type: InteractPolicyComponent.EntityType,
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

			var pending_entities: Array[Entity] = cell.get_entity_group(faction, entity_type)
			for entity: Entity in pending_entities:
				if not MathUtils.is_in_ellipse_ring(search_global_position, entity.global_position, min_range, max_range, aspect):
					continue
					
				entities.append(entity)

	return entities


## 通过空间哈希网格搜索椭圆环范围内目标。[br][br]
## [param filter]: 过滤函数。返回 [code]false[/code] 表示被过滤。[br][br]
## 与 [method EntityManager.search_entities_in_ellipse] 不同的是，支持过滤函数。
func search_entities_in_ellipse_filtered(
		search_global_position: Vector2,
		min_range: float,
		max_range: float,
		faction: InteractPolicyComponent.Faction,
		entity_type: InteractPolicyComponent.EntityType,
		filter := Callable(),
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

			var pending_entities: Array[Entity] = cell.get_entity_group(faction, entity_type)
			for entity: Entity in pending_entities:
				if not MathUtils.is_in_ellipse_ring(search_global_position, entity.global_position, min_range, max_range, aspect):
					continue
					
				if not filter.call(entity):
					continue
					
				entities.append(entity)

	return entities


## 分组实体。
func _grouping_entities() -> void:
	for cell: SpaceIndexCell in spatial_hash_grid:
		cell.clear()

	for entity: Entity in EntityManager.get_valid_entities():
		var cell_index: int = global_position_to_spatial_hash_cell_index(entity.global_position)
		var cell: SpaceIndexCell = get_spatial_hash_cell(cell_index)
		
		var interact_policy_c: InteractPolicyComponent = entity.get_node_or_null(Constants.INTERACT_POLICY_COMPONENT_NODE_PATH)
		if not interact_policy_c:
			continue
		
		var interact_policy_c_config: InteractPolicyComponentNodeConfig = interact_policy_c.config
		var interact_policy_c_config_entity_type: InteractPolicyComponent.EntityType = interact_policy_c_config.entity_type
		for entity_type: InteractPolicyComponent.EntityType in InteractPolicyComponent.EntityType.values():
			if not entity_type & interact_policy_c_config_entity_type:
				continue

			var group_key: int = interact_policy_c_config.faction << Constants.INT64_LEN_HALF | entity_type
			cell.entity_groups[group_key].append(entity)


## 空间哈希网格单元。
class SpaceIndexCell extends RefCounted:
	## 网格内的实体组。
	var entity_groups: Dictionary[int, EntityGroup] = {}

	func _init() -> void:
		for faction: InteractPolicyComponent.Faction in InteractPolicyComponent.Faction.values():
			var shifted_faction: int = faction << Constants.INT64_LEN_HALF
			for entity_type: InteractPolicyComponent.EntityType in InteractPolicyComponent.EntityType.values():
				entity_groups[shifted_faction | entity_type] = EntityGroup.new()

	func get_entity_group(faction: InteractPolicyComponent.Faction, entity_type: InteractPolicyComponent.EntityType) -> Array[Entity]:
		var group_key: int = faction << Constants.INT64_LEN_HALF | entity_type
		return entity_groups[group_key].get_entities()

	func clear() -> void:
		for entity_group: EntityGroup in entity_groups.values():
			entity_group.clear()
