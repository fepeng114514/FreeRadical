extends Path2D
class_name Pathway
## 路径类


## 是否禁用当前路径
@export var disabled: bool = true
## 子路径列表
var subpathway_list: Array[Subpathway] = []
## 下一个子路径索引
var next_spi: int = 0
## 路径索引
var idx: int = C.UNSET


func _ready() -> void:
	var max_subpathway: int = PathwayMgr.max_subpathway
	var spacing: float = PathwayMgr.subpathway_spacing
	
	var half_total_spacing: float = max_subpathway * spacing / 2

	for i: int in range(max_subpathway):
		var subpathway := Subpathway.new()
		subpathway.spacing = half_total_spacing - (spacing * i)
		subpathway.parent_pathway = self
		subpathway.idx = next_spi
		add_child(subpathway)

		subpathway_list.append(subpathway)

		next_spi += 1
		#
		#if not Engine.is_editor_hint():
			#return
	#
		#var line := Line2D.new()
		#line.width = 3.0
		#line.default_color = Color.RED
#
		## 从曲线获取点
		#var c: Curve2D = subpathway.curve
		#line.points = c.get_baked_points()
#
		#subpathway.add_child(line)
