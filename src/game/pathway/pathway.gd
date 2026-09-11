#@tool
extends Path2D
class_name Pathway
## 路径。


## 是否禁用当前路径
@export var disabled: bool = false

## 子路径数组
var sub_pathways: Array[SubPathway] = []
## 下一个子路径索引
var next_spi: int = 0
## 路径索引
var index: int = Constants.UNSET


func _ready() -> void:
	PathwayManager.insert_pathway(self)
	
	var sub_pathway_count: int = PathwayManager.sub_pathway_count
	var spacing: float = PathwayManager.sub_pathway_spacing
	
	var half_total_spacing: float = sub_pathway_count * spacing / 2

	for sub_pathway_index: int in sub_pathway_count:
		var sub_pathway := SubPathway.new()
		sub_pathway.spacing = half_total_spacing - (spacing * sub_pathway_index)
		sub_pathway.parent_pathway = self
		sub_pathway.index = next_spi
		add_child(sub_pathway)

		sub_pathways.append(sub_pathway)

		next_spi += 1
