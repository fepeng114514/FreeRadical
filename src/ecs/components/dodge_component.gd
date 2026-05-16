@tool
extends Node
class_name DodgeComponent


func _get_configuration_warnings() -> PackedStringArray:
	if not get_children():
		return ["请至少增加一个 Skill 节点或其类型的节点，否则实体无法反击。"]
		
	return []
