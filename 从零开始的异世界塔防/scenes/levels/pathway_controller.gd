extends Node
class_name PathwayController
## 路径管理器
##
## 管理路径子节点 [Pathway]


func _ready() -> void:
	for child: Node in get_children():
		if child is not Pathway:
			continue
			
		PathwayMgr.insert_pathway(child)
