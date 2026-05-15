@tool
extends Node
class_name DodgeComponent


var list: Array[SkillBase] = []


func _ready() -> void:
	for child: SkillBase in get_children():
		list.append(child)


func _get_configuration_warnings() -> PackedStringArray:
	if not get_children():
		return ["请至少增加一个 SkillBase 节点或其类型的节点，否则实体无法反击。"]
		
	return []
