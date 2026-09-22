#@tool
extends Path2D
class_name SubPathway
## 子路径。


var follow: PathFollow2D = null
## 子路径索引
var index: int = Constants.UNSET
## 偏移量
var offset: float = 0.0
## 节点列表
var node_list: Array[PathwayNode] = []
## 子路径长度
var length: float = 0.0
## 父路径
var parent_pathway: Pathway = null


func _ready() -> void:
	follow = PathFollow2D.new()
	follow.name = "Follow"
	follow.loop = false

	add_child(follow)
	
	length = curve.get_baked_length()
	node_list = _get_equally_spaced_nodes()

	DebugManager.draw_state_changed.connect(_on_draw_state_changed)


func _draw() -> void:
	if DebugManager.draw_pathway_enabled or Engine.is_editor_hint():
		for node: PathwayNode in node_list:
			var pathway_index: int = parent_pathway.get_index()
			var hue: float = fmod(pathway_index * 0.1, 1.0)           # 0.1 步长可调整，避免相邻颜色太接近
			var color: Color = Color.from_hsv(hue, 1.0, 1.0) # 饱和度、亮度最大
			draw_circle(to_local(node.global_position), 3, color)


## 获取等距的节点列表
func _get_equally_spaced_nodes() -> Array[PathwayNode]:
	var nodes_list: Array[PathwayNode] = []
	
	var point_spacing: float = length / (PathwayManager.node_count - 1)
	
	for node_index: int in PathwayManager.node_count:
		var distance: float = node_index * point_spacing
		var sample_position: Vector2 = curve.sample_baked(distance)
		
		var node := PathwayNode.new()
		node.pathway_index = parent_pathway.index
		node.sub_pathway_index = index
		node.index = node_index
		node.global_position = to_global(sample_position)
		node.ratio = clampf(distance / length, 0, 1)
		node.progress = distance

		nodes_list.append(node)
		PathwayManager.all_nodes.append(node)
	
	return nodes_list


func _on_draw_state_changed(_draw_type: DebugManager.DrawType) -> void:
	queue_redraw()
