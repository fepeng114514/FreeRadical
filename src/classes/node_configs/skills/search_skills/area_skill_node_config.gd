@tool
extends SearchSkillNodeConfig
class_name AreaSkillNodeConfig
## 范围技能节点配置资源。


## 影响资源，用于对目标造成伤害或治愈目标。
@export var influence: Influence = null:
	set(v):
		influence = v
		emit_changed()
