@tool
extends Node2D
## 路径管理器
##
## 管理路径子节点 [Pathway]


func _ready() -> void:
	if Engine.is_editor_hint():
		return
		
	_process_path_intersection()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
		
	if not get_children():
		warnings.append("请至少增加一个 Pathway 子节点，否则所有路径相关的操作会出错。")
		
	return warnings


## 处理路径相交。
func _process_path_intersection() -> void:
	var all_nodes: Array[PathwayNode] = PathwayManager.all_nodes
	var threshold: float = PathwayManager.intersect_dist_threshold
	var cell_size: float = threshold

	var grid: Dictionary[Array, Array] = {}

	for node: PathwayNode in all_nodes:
		var cell_x := int(node.global_position.x / cell_size)
		var cell_y := int(node.global_position.y / cell_size)
		var cell_key: Array[int] = [cell_x, cell_y]

		var cell: Array = grid.get_or_add(cell_key, [])
		cell.append(node)
		
	for node: PathwayNode in all_nodes:
		var cell_x := int(node.global_position.x / cell_size)
		var cell_y := int(node.global_position.y / cell_size)
		
		# 检查 3x3 邻域网格
		for dx: int in range(-1, 2):
			for dy: int in range(-1, 2):
				var neighbor_key: Array[int] = [cell_x + dx, cell_y + dy]
				if not grid.has(neighbor_key):
					continue
				
				for other_node: PathwayNode in grid[neighbor_key]:
					if other_node.pathway_index== node.pathway_index:
						continue
					
					if node.global_position.distance_to(other_node.global_position) > threshold:
						continue
					
					node.intersecting_node_index_list.append(other_node.index)
					other_node.intersecting_node_index_list.append(node.index)
