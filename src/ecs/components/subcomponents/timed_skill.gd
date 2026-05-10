@tool
extends Node2D
class_name TimedSkill

## 攻击标识
@export var flags: int = 0
@export var cooldown: float = 1

@export_group("Limit")
## 不可攻击的实体的标识
@export var bans: int = 0
## 可攻击的实体场景名称
@export var whitelist := PackedStringArray()
## 不可以攻击的实体场景名称
@export var blacklist := PackedStringArray()
@export_subgroup("Need Find Target")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var need_find_target_enable: bool = false
## 最小攻击距离
@export var min_range: float = 0:
	set(value):
		min_range = value
		queue_redraw()
## 最大攻击距离
@export var max_range: float = 300:
	set(value):
		max_range = value
		queue_redraw()
## 目标搜索模式
@export var search_mode: C.SearchMode = C.SearchMode.ENEMY_MAX_PROGRESS

var ts: float = 0


func _draw() -> void:
	if Engine.is_editor_hint():
		draw_circle(
			position, 
			max_range,
			Color(0.401, 0.865, 0.386, 0.604), 
			false,
			6
		)
		draw_circle(
			position, 
			min_range,
			Color(0.401, 0.865, 0.386, 0.604), 
			false,
			6
		)
