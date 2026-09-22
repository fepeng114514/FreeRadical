#@tool
extends Path2D
class_name Pathway
## 路径。


## 是否禁用当前路径
@export var disabled: bool = false

## 子路径数组
var sub_pathways: Array[SubPathway] = []
## 下一个子路径索引
var next_sub_pathway_index: int = 0
## 路径索引
var index: int = Constants.UNSET


func _ready() -> void:
	PathwayManager.insert_pathway(self)
	
	var sub_pathway_count: int = PathwayManager.sub_pathway_count
	var spacing: float = PathwayManager.sub_pathway_spacing
	var half_total_spacing: float = (sub_pathway_count - 1) * spacing / 2

	for sub_pathway_index: int in sub_pathway_count:
		var sub_pathway := SubPathway.new()
		sub_pathway.parent_pathway = self
		sub_pathway.index = next_sub_pathway_index

		var offset: float = half_total_spacing - (spacing * sub_pathway_index)
		sub_pathway.offset = offset
		sub_pathway.curve = _create_offset_curve(offset)
		
		add_child(sub_pathway)
		sub_pathways.append(sub_pathway)

		next_sub_pathway_index += 1


## 创建偏移曲线
func _create_offset_curve(offset: float) -> Curve2D:
	var new_curve := Curve2D.new()

	var curve_length: float = curve.get_baked_length()
	var sample_step: float = 2.0
	var sample_count: int = maxi(2, int(curve_length / sample_step) + 1)
	var end_sample_index: int = sample_count - 1

	for sample_index: int in sample_count:
		var distance: float = curve_length if sample_index == end_sample_index else sample_index * sample_step

		var sample_transform: Transform2D = curve.sample_baked_with_rotation(distance)
		var offset_point: Vector2 = sample_transform.origin + sample_transform.y * offset
		new_curve.add_point(offset_point)

	return new_curve
