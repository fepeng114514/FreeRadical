extends Path2D
class_name Pathway
## 路径。


## 是否禁用当前路径
@export var disabled: bool = false

## 子路径列表
var sub_pathway_list: Array[SubPathway] = []
## 下一个子路径索引
var next_spi: int = 0
## 路径索引
var idx: int = C.UNSET


func _ready() -> void:
	PathwayMgr.insert_pathway(self)
	
	var sub_pathway_count: int = PathwayMgr.sub_pathway_count
	var spacing: float = PathwayMgr.sub_pathway_spacing
	
	var half_total_spacing: float = sub_pathway_count * spacing / 2

	for i: int in sub_pathway_count:
		var sub_pathway := SubPathway.new()
		sub_pathway.spacing = half_total_spacing - (spacing * i)
		sub_pathway.parent_pathway = self
		sub_pathway.idx = next_spi
		add_child(sub_pathway)

		sub_pathway_list.append(sub_pathway)

		next_spi += 1
