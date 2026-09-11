@icon("res://assets/dpi_textures/at-icons/node2d/itinerary.svg")
extends Component
class_name NavPathComponent
## 导航路径组件。
##
## NavPathComponent 可以使实体沿着路径移动。


## 是否沿相反路线移动。
@export var reversed_enabled: bool = false
## 移动速度。
@export var speed: float = 133.0
## 移动动画组。
@export var motion_animation: AnimationGroup = null
## 是否强制与来源实体所在路径同步。
@export var sync_source_path: bool = true

@export_group("End")
## 终点节点。
@export var end_pathway_node_index: int = Constants.UNSET
## 是否启用循环。
@export var loop_enabled: bool = false
## 循环次数，循环指定次数后再到达终点节点将会到达终点。
@export var loop_times: int = Constants.UNSET
## 到达终点消耗的生命。
@export var life_cost: int = 1

## 所在路径索引。
var pathway_index: int = 0
## 所在子路径索引。
var sub_pathway_index: int = 0
## 所在节点索引。
var pathway_node_index: int = 0
## 所在路程比率。
var ratio: float = 0.0
## 所在路程。
var progress: float = 0.0
## 当前循环次数。
var loop_count: int = 0
## 时间戳。
var ts: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	

## [method PathwayManager.get_subpath] 的简写，已传递 [param pathway_index], [param sub_pathway_index]
func get_subpath() -> Path2D:
	return PathwayManager.get_subpath(pathway_index, sub_pathway_index)


## [method PathwayManager.calculate_progress_ratio] 的简写，已传递 [param pathway_index], [param sub_pathway_index]
func calculate_progress_ratio(p_progress: float = progress) -> float:
	return PathwayManager.calculate_progress_ratio(pathway_index, sub_pathway_index, p_progress)
	

## [method PathwayManager.get_ratio_global_position] 的简写，已传递 [param pathway_index], [param sub_pathway_index]
func get_ratio_global_position(p_ratio: float = ratio) -> Vector2:
	return PathwayManager.get_ratio_global_position(pathway_index, sub_pathway_index, p_ratio)
	

## [method PathwayManager.get_progress_global_position] 的简写，已传递 [param pathway_index], [param sub_pathway_index]
func get_progress_global_position(p_progress: float = progress) -> Vector2:
	return PathwayManager.get_progress_global_position(pathway_index, sub_pathway_index, p_progress)


## [method PathwayManager.get_progress_by_ratio] 的简写，已传递 [param pathway_index], [param sub_pathway_index]
func get_progress_by_ratio(p_ratio: float = ratio) -> float:
	return PathwayManager.get_progress_by_ratio(pathway_index, sub_pathway_index, p_ratio)


## [method PathwayManager.get_pathway_node] 的简写，已传递 [param pathway_index], [param sub_pathway_index]
func get_pathway_node(index: int = pathway_node_index) -> PathwayNode:
	return PathwayManager.get_pathway_node(pathway_index, sub_pathway_index, index)


## 设置导航路径。
func set_nav_path(
		p_pathway_index: int, p_sub_pathway_index: int = Constants.UNSET, node_index: int = Constants.UNSET
	) -> void:
	pathway_index = p_pathway_index
	sub_pathway_index = p_sub_pathway_index
	if Utils.is_valid_number(node_index):
		pathway_node_index = node_index


## 根据某个路径节点进行导航。
func navigate_to_node(node: PathwayNode) -> void:
	pathway_node_index = node.node_index
	progress = node.progress
	ratio = node.ratio


## 设置导航路径到全局位置下最近的导航路径
func set_nav_path_to_nearest_node(entity: Entity, search_global_position: Vector2) -> void:
	var nav_path_c: NavPathComponent = get_node_or_null(Constants.CN_NAV_PATH)
	var pi_list: Array = []
	var spi_list: Array = []

	if nav_path_c.sync_source_path:
		var source: Entity = ECSEntityManager.get_entity_by_id(entity.source_id)
		var s_nav_path_c: NavPathComponent = source.get_node_or_null(Constants.CN_NAV_PATH) if source else null
		if s_nav_path_c:
			pi_list = [s_nav_path_c.pi]
			spi_list = [s_nav_path_c.spi]

	var node: PathwayNode = PathwayManager.find_nearest_node_to_global_position(search_global_position, pi_list, spi_list)
	nav_path_c.set_nav_path(node.pathway_index, node.sub_pathway_index, node.index)

