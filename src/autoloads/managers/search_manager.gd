extends Node
## 搜索管理器。
##
## 负责搜索实体的相关操作。


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
	_clear()

	var world_size: Vector2 = GlobalMgr.world_size
	var grid_count_x: int = ceili(world_size.x / SPACE_INDEX_GRID_SIZE)
	var grid_count_y: int = ceili(world_size.y / SPACE_INDEX_GRID_SIZE)
	
	for x: int in grid_count_x:
		var grid_col: Dictionary = {
			"row": [],
			"has_entity": false,
			"has_enemy": false,
			"has_friendly": false,
			"has_unit": false,
			"has_tower": false,
		}
		var grid_row: Array = grid_col.row

		for y: int in grid_count_y:
			grid_row.append({
				C.GROUP_ENTITY: [],
				C.GROUP_ENEMY: [],
				C.GROUP_FRIENDLY: [],
				C.GROUP_UNIT: [],
				C.GROUP_TOWER: [],
			})

		space_index_grid_list.append(grid_col)
	
	space_index_grid_count_x = grid_count_x
	space_index_grid_count_y = grid_count_y


func _clear() -> void:
	space_index_grid_list.clear()
	

## 搜索范围内目标，filter 返回 false 表示被过滤。
func find_targets_in_range(
		origin: Vector2,
		max_range: float,
		min_range: float = 0.0,
		flags: int = 0,
		bans: int = 0,
		filter: Callable = Callable(),
		group: StringName = C.GROUP_ENTITY
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
			for e: Entity in grid_row[grid_y][group]:
				if e.state & Entity.State.DEAD:
					continue
				
				var interact_p: InteractPolicy = e.interact_policy
				if interact_p and U.is_mutual_banned(interact_p.flags, bans, flags, interact_p.bans):
					continue
				
				if not U.is_in_ring(origin, e.global_position, min_range, max_range):
					continue
					
				if filter.is_valid() and not filter.call(e):
					continue
					
				targets.append(e)

	return targets
