@tool
extends Node2D
class_name SkillComponent
## 技能组件
##
## SkillComponent 可以使实体拥有释放技能的能力，技能以 [SkillBase] 子节点的形式存在。

		
func _get_configuration_warnings() -> PackedStringArray:
	if not get_children():
		return ["请至少增加一个 SkillBase 或其类型的子节点，否则实体无法释放技能。"]
		
	return []
