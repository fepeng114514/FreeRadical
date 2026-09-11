extends Node
## 路径管理器。
##
## 负责管理路径与相关操作。


@warning_ignore_start("unused_signal")
## 路径绘制状态发生更改时发出。
signal draw_pathway_changed
@warning_ignore_restore("unused_signal")


## 路径列表。
var _pathways: Array[Pathway] = []
## 所有路径上的节点列表。
var all_nodes: Array[PathwayNode] = []
## 下一个路径索引。
var next_pathway_index: int = 0
## 子路径总数量。
var sub_pathway_count: int = 5
## 子路径间距。
var sub_pathway_spacing: float = 20.0
## 路径节点总数量。
var node_count: int = 256
## 路径节点相交距离阈值。
var intersect_dist_threshold: float = 10.0
## 是否绘制路径。
var is_draw_pathway: bool = false:
	set(v):
		is_draw_pathway = v
		draw_pathway_changed.emit()
	

func clear() -> void:
	_pathways.clear()
	all_nodes.clear()
	next_pathway_index = 0
	

## 插入路径。
func insert_pathway(pathway: Pathway) -> void:
	pathway.index = next_pathway_index
	next_pathway_index += 1
	_pathways.append(pathway)


## 获取路径数量。
func get_pathway_count() -> int:
	return _pathways.size()


## 获取指定索引的路径。
func get_pathway(pathway_index: int) -> Pathway:
	return _pathways[pathway_index]


## 获取指定索引的子路径。
func get_sub_pathway(pathway_index: int, sub_pathway_index: int) -> SubPathway:
	var pathway: Pathway = _pathways[pathway_index]
	var sub_pathway: SubPathway = pathway.sub_pathways[sub_pathway_index]
	return sub_pathway


## 获取指定索引的节点。
func get_pathway_node(pathway_index: int, sub_pathway_index: int, index: int) -> PathwayNode:
	var pathway: Pathway = _pathways[pathway_index]
	var sub_pathway: SubPathway = pathway.sub_pathways[sub_pathway_index]
	var pathway_node: PathwayNode = sub_pathway.node_list[index]

	return pathway_node
	

## 获取中间的子路径索引。
func get_middle_sub_pathway_index() -> int:
	return roundi(1.0 * sub_pathway_count / 2)


## 获取启用的路径。
func get_enabled_pathways() -> Array[Pathway]:
	return _pathways.filter(func(pathway: Pathway): return not pathway.disabled)


## 获取随机路径。
func get_random_pathway() -> Pathway:
	return _pathways.pick_random()


## 获取随机路径索引。
func get_random_pathway_index() -> int:
	return randi_range(0, get_pathway_count() - 1)


## 获取指定路径上的随机子路径。[br][br]
## [param pathway_index]: 路径索引。路径索引为 -1 时获取随机路径。
func get_random_sub_pathway(pathway_index: int = Constants.UNSET) -> SubPathway:
	if not Utils.is_valid_number(pathway_index):
		pathway_index = get_random_pathway_index()

	var pathway: Pathway = _pathways[pathway_index]

	return pathway.sub_pathways.pick_random()


## 根据路程计算路程比率。
func calculate_progress_ratio(pathway_index: int, sub_pathway_index: int, progress: float) -> float:
	var sub_pathway: SubPathway = get_sub_pathway(pathway_index, sub_pathway_index)
		
	var delta: float = progress / sub_pathway.length
	return clampf(delta, 0, 1)
	

## 获取指定路径比率上的全局位置。
func get_ratio_global_position(pathway_index: int, sub_pathway_index: int, ratio: float) -> Vector2:
	var sub_pathway: SubPathway = get_sub_pathway(pathway_index, sub_pathway_index)	
	var path_follow: PathFollow2D = sub_pathway.follow
		
	path_follow.progress_ratio = ratio
	var global_position: Vector2 = path_follow.global_position
	
	return global_position


## 根据路程比率获取路程。
func get_progress_by_ratio(pathway_index: int, sub_pathway_index: int, ratio: float) -> float:
	var sub_pathway: SubPathway = get_sub_pathway(pathway_index, sub_pathway_index)	

	return sub_pathway.length * ratio
	

## 获取指定路程上的全局位置。
func get_progress_global_position(pathway_index: int, sub_pathway_index: int, progress: float) -> Vector2:
	var sub_pathway: SubPathway = get_sub_pathway(pathway_index, sub_pathway_index)
	var path_follow: PathFollow2D = sub_pathway.follow
		
	path_follow.progress = progress
	var global_position: Vector2 = path_follow.global_position
	
	return global_position
	

## 预判目标全局位置。
func predict_target_global_position(target: Entity, predict_time: float) -> Vector2:
	var predicted_global_position: Vector2 = target.global_position

	var nav_path_c: NavPathComponent = target.get_node_or_null(Constants.CN_NAV_PATH)
	if nav_path_c and target.state & Entity.State.NAV_PATH_WALK:
		var progress: float = nav_path_c.progress
		var walk_lenth: float = nav_path_c.speed * predict_time
		
		if nav_path_c.reversed_enabled:
			progress -= walk_lenth
		else:
			progress += walk_lenth
	
		predicted_global_position = nav_path_c.get_progress_global_position(
			progress
		)
	
	return predicted_global_position
	

## 获取指定路径上按距离排序的节点列表。[br][br]
## [param pathway_index_list]: 路径索引列表。默认搜索所有路径。[br]
## [param sub_pathway_index_list]: 子路径索引列表。默认搜索所有子路径。[br][br]
## [param only_valid]: 是否只搜索已启用的路径。
## [b]注意[/b]: 为了性能考虑，如果只需要一个最近节点，建议使用 [method find_nearest_node_to_global_position]。
func find_nearest_nodes_to_global_position(
		search_global_position: Vector2, 
		pathway_index_list: Array = range(get_pathway_count()), 
		sub_pathway_index_list: Array = range(sub_pathway_count),
		only_valid: bool = true
	) -> Array[PathwayNode]:
	var node_list: Array[PathwayNode] = []

	for pathway_index: int in pathway_index_list:
		if only_valid and not get_pathway(pathway_index).is_disabled():
			continue

		for sub_pathway_index: int in sub_pathway_index_list:
			var sub_pathway: SubPathway = get_sub_pathway(pathway_index, sub_pathway_index)

			for node: PathwayNode in sub_pathway.node_list:
				node.dist_squared = node.global_position.distance_squared_to(search_global_position)

				node_list.append(node)

	node_list.sort_custom(
		func(p1: PathwayNode, p2: PathwayNode): 
			return p1.dist_squared < p2.dist_squared
	)
	return node_list
	

## 获取全局位置上最近的路径上的一个节点。[br][br]
## [param pathway_index_list]: 路径索引列表。默认搜索所有路径。[br]
## [param sub_pathway_index_list]: 子路径索引列表。默认搜索所有子路径。
## [param only_valid]: 是否只搜索已启用的路径。
func find_nearest_node_to_global_position(
		search_global_position: Vector2, 
		pathway_index_list: Array = range(get_pathway_count()), 
		sub_pathway_index_list: Array = range(sub_pathway_count),
		only_valid: bool = true
	) -> PathwayNode:
	var nearest_node: PathwayNode = null
	
	for pathway_index: int in pathway_index_list:
		if only_valid and not get_pathway(pathway_index).is_disabled():
			continue
		
		for sub_pathway_index: int in sub_pathway_index_list:
			var sub_pathway: SubPathway = get_sub_pathway(pathway_index, sub_pathway_index)
			
			for node: PathwayNode in sub_pathway.node_list:
				node.dist_squared = node.global_position.distance_squared_to(search_global_position)
				
				if (
						not nearest_node
						or node.dist_squared 
						< nearest_node.dist_squared
				):
					nearest_node = node

	return nearest_node
