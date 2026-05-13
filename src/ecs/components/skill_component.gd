@tool
extends Node2D
class_name SkillComponent
## 技能组件
##
## SkillComponent 可以使实体拥有定时释放技能的能力，与远程攻击不同的是不会召唤子弹，技能以 SkillBase 资源的形式存在于组件的子节点中。


func _get_configuration_warnings() -> PackedStringArray:
	if not get_children():
		return ["请至少增加一个 SkillBase 或其类型的子节点，否则实体无法使用技能。"]
		
	return []
