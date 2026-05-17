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
## 技能标识
@export var flags: C.Flag = C.Flag.NONE
## 不可搜索的目标的标识
@export var bans: int = 0
## 可搜索的目标的场景名称列表
@export var whitelist := PackedStringArray()
## 不可搜索的目标的场景名称列表
@export var blacklist := PackedStringArray()



func _ready() -> void:
	U.connect_resource_changed(influence, queue_redraw)


func _draw() -> void:
	if Engine.is_editor_hint():
		if influence:
			influence.draw(self, position)
