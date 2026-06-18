#@tool
extends Path2D
class_name SubPathway
## 子路径。


var follow: PathFollow2D = null
## 子路径索引
var idx: int = C.UNSET
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

	PathwayMgr.draw_pathway_changed.connect(queue_redraw)


func _draw() -> void:
	if PathwayMgr.is_draw_pathway or Engine.is_editor_hint():
		for node: PathwayNode in node_list:
			var pi: int = parent_pathway.get_index()
			var hue: float = fmod(pi * 0.1, 1.0)           # 0.1 步长可调整，避免相邻颜色太接近
			var color: Color = Color.from_hsv(hue, 1.0, 1.0) # 饱和度、亮度最大
			draw_circle(node.pos, 3, color)


## 创建偏移曲线
func _create_offset_curve() -> Curve2D:
	var source_pathway_curve: Curve2D = parent_pathway.curve
	var new_curve := Curve2D.new()
	
	# 沿着曲线采样多个点
	var sample_points := PackedVector2Array()
	var offset_points := PackedVector2Array()
	
	# 获取曲线的长度
	var curve_length: float = source_pathway_curve.get_baked_length()
	# 提高采样密度
	var sample_count: int = maxi(2, int(curve_length))
	
	# 均匀采样
	for i: int in sample_count:
		var t: float = float(i) / (sample_count - 1)
		var distance: float = t * curve_length
		var point: Vector2 = source_pathway_curve.sample_baked(distance)
		sample_points.append(point)
	
	# 计算每个采样点的偏移
	for i: int in sample_points.size():
		var tangent := Vector2.ZERO
		
		# 使用中心差分计算切线
		if i > 0 and i < sample_points.size() - 1:
			tangent = (sample_points[i + 1] - sample_points[i - 1]).normalized()
		elif i > 0:
			tangent = (sample_points[i] - sample_points[i - 1]).normalized()
		elif i < sample_points.size() - 1:
			tangent = (sample_points[i + 1] - sample_points[i]).normalized()
		
		if tangent.length_squared() > 0:
			# 计算法线（相反方向）
			var normal := Vector2(tangent.y, -tangent.x)
			var offset_point: Vector2 = sample_points[i] + normal * spacing
			offset_points.append(offset_point)
		else:
			offset_points.append(sample_points[i])
	
	# 将偏移点添加到新曲线
	for i: int in offset_points.size():
		var point: Vector2 = offset_points[i]
		new_curve.add_point(point)
	
	return new_curve


## 获取等距的节点列表
func _get_equally_spaced_nodes() -> Array[PathwayNode]:
	var nodes_list: Array[PathwayNode] = []
	
	var point_spacing: float = length / (PathwayMgr.node_count - 1)
	
	for i: int in PathwayMgr.node_count:
		var distance: float = i * point_spacing
		var pos: Vector2 = curve.sample_baked(distance)
		
		var n := PathwayNode.new()
		n.pi = parent_pathway.idx
		n.spi = idx
		n.ni = i
		n.pos = pos
		n.ratio = clampf(distance / length, 0, 1)
		n.progress = distance

		nodes_list.append(n)
		PathwayMgr.all_node_list.append(n)
	
	return nodes_list
