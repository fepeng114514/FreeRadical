@tool
extends Skill
class_name SkillMelee
## 近战技能节点
##
## 用于 [MeleeComponent]


## 伤害/治疗/范围伤害 统一资源
@export var influence: InfluenceResource = null:
	set(value):
		influence = value
		if Engine.is_editor_hint():
			U.connect_resource_changed(influence, queue_redraw)
			queue_redraw()
@export var search_target_pos: bool = false
@export var interact_policy: InteractPolicy = null


func _ready() -> void:
	U.connect_resource_changed(influence, queue_redraw)


func _draw() -> void:
	if Engine.is_editor_hint():
		if influence:
			influence.draw(self, position)
