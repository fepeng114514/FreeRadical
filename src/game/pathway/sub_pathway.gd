#@tool
extends Path2D
class_name SubPathway
## 子路径。


var follow: PathFollow2D = null
## 子路径索引
var index: int = Constants.UNSET
## 间距
var spacing: float = 0.0
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
	curve = _create_offset_curve()
	length = curve.get_baked_length()
	node_list = _get_equally_spaced_nodes()

	DebugManager.draw_state_changed.connect(_on_draw_state_changed)


func _draw() -> void:
	if DebugManager.draw_pathway_enabled or Engine.is_editor_hint():
		for node: PathwayNode in node_list:
			var pathway_index: int = parent_pathway.get_index()
			var hue: float = fmod(pathway_index * 0.1, 1.0)           # 0.1 步长可调整，避免相邻颜色太接近
			var color: Color = Color.from_hsv(hue, 1.0, 1.0) # 饱和度、亮度最大
			draw_circle(node.position, 3, color)


## 创建偏移曲线
func _create_offset_curve() -> Curve2D:
	# 复制源曲线并加密烘焙，避免源曲线默认 5px 烘焙间隔在弯道处引入采样误差
	var source_pathway_curve: Curve2D = parent_pathway.curve.duplicate()
	source_pathway_curve.bake(1.0)

	var new_curve := Curve2D.new()
	# 与采样步长保持一致，保证重新烘焙后的长度与采样折线一致
	new_curve.bake_interval = 1.0

	var curve_length: float = source_pathway_curve.get_baked_length()
	# 固定较小的采样步长，步长越小弯道处的等距偏移越精确
	var sample_step: float = 2.0
	var sample_count: int = maxi(2, int(curve_length / sample_step) + 1)

	for sample_index: int in sample_count:
		# 末个采样点直接取曲线终点，避免浮点误差导致终点缺失
		var distance: float = curve_length if sample_index == sample_count - 1 else sample_index * sample_step
		# 直接获取该点的位置与切线方向，比中心差分更贴近真实曲线
		var sample_transform: Transform2D = source_pathway_curve.sample_baked_with_rotation(distance)
		var tangent: Vector2 = sample_transform.x
		var normal := Vector2(tangent.y, -tangent.x)
		var offset_point: Vector2 = sample_transform.origin + normal * spacing
		new_curve.add_point(offset_point)

	return new_curve


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
