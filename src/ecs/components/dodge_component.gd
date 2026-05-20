@tool
extends Node
class_name DodgeComponent
## 闪避组件
##
## DodgeComponent 可以使实体拥有闪避与反击的能力，反击技能以 [Skill] 子节点的形式存在。


func _get_configuration_warnings() -> PackedStringArray:
	if not get_children():
		return ["请至少增加一个 Skill 节点或其类型的节点，否则实体无法反击。"]
		
	return []
