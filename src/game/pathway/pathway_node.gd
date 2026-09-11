extends RefCounted
class_name PathwayNode
## 路径节点资源。
##
## PathwayNode 用于表示路径上的一个节点，包含节点的位置、比率、位置等信息。


## 路径索引。
var pathway_index: int = Constants.UNSET
## 子路径索引。
var sub_pathway_index: int = Constants.UNSET
## 路径节点索引。
var index: int = Constants.UNSET
## 节点全局位置。	
var global_position := Vector2.ZERO
## 位于的路径比率。
var ratio: float = 0.0
## 位于的路径位置。
var progress: float = 0.0
## 距离。
var dist_squared: float = 0.0
## 与另一个路径相交的节点索引列表。
var intersecting_node_index_list: Array[int] = []


## [method PathwayManager.get_subpath] 的简写，已传递 [param pi], [param spi]
func get_subpath() -> Path2D:
	return PathwayManager.get_subpath(pathway_index, sub_pathway_index)


## [method PathwayManager.calculate_progress_ratio] 的简写，已传递 [param pi], [param spi]
func calculate_progress_ratio(_progress: float = progress) -> float:
	return PathwayManager.calculate_progress_ratio(pathway_index, sub_pathway_index, progress)
	

## [method PathwayManager.get_ratio_global_position] 的简写，已传递 [param pi], [param spi]
func get_ratio_global_position(p_ratio: float = ratio) -> Vector2:
	return PathwayManager.get_ratio_global_position(pathway_index, sub_pathway_index, p_ratio)
	

## [method PathwayManager.get_progress_global_position] 的简写，已传递 [param pi], [param spi]
func get_progress_global_position(p_progress: float = progress) -> Vector2:
	return PathwayManager.get_progress_global_position(pathway_index, sub_pathway_index, p_progress)


## [method PathwayManager.get_progress_by_ratio] 的简写，已传递 [param pi], [param spi]
func get_progress_by_ratio(p_ratio: float = ratio) -> float:
	return PathwayManager.get_progress_by_ratio(pathway_index, sub_pathway_index, p_ratio)


## [method PathwayManager.get_pathway_node] 的简写，已传递 [param pathway_index], [param sub_pathway_index]
func get_pathway_node(p_index: int = index) -> PathwayNode:
	return PathwayManager.get_pathway_node(pathway_index, sub_pathway_index, p_index)
