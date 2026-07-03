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
	var warnings: PackedStringArray = []
		
	if not get_children():
		warnings.append("请至少增加一个 Pathway 子节点，否则所有路径相关的操作会出错。")
		
	return warnings


## 处理路径相交。
func _process_path_intersection() -> void:
	var all_node_list: Array[PathwayNode] = PathwayMgr.all_node_list
	var threshold: float = PathwayMgr.intersect_dist_threshold
	var cell_size: float = threshold

	var grid: Dictionary[Array, Array] = {}

	for n: PathwayNode in all_node_list:
		var cell_x := int(n.pos.x / cell_size)
		var cell_y := int(n.pos.y / cell_size)
		var cell_key: Array[int] = [cell_x, cell_y]
		
		if not grid.has(cell_key):
			grid[cell_key] = []
		grid[cell_key].append(n)
		
	# 只检查相邻网格内的节点
	for n: PathwayNode in all_node_list:
		var cell_x := int(n.pos.x / cell_size)
		var cell_y := int(n.pos.y / cell_size)
		
		# 检查 3x3 邻域网格（当前格 + 周围8格）
		for dx: int in range(-1, 2):
			for dy: int in range(-1, 2):
				var neighbor_key: Array[int] = [cell_x + dx, cell_y + dy]
				if not grid.has(neighbor_key):
					continue
				
				for other_n: PathwayNode in grid[neighbor_key]:
					# 同一路径的点不比较
					if other_n.pi == n.pi:
						continue
					
					# 距离检测
					if n.pos.distance_to(other_n.pos) > threshold:
						continue
					
					n.intersecting_node_idx_list.append(other_n.ni)
					other_n.intersecting_node_idx_list.append(n.ni)
