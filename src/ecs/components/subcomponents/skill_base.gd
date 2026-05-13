@tool
extends Node2D
class_name SkillBase


## 攻击标识
@export var flags: int = 0
@export var cooldown: float = 1
@export var spawns: Array[StringName] = []

@export_group("Entity Group Cooldown")
## 是否启用实体组冷却
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var group_cooldown_enable: bool = false
## 实体组冷却偏移
@export var group_cooldown_offset: float = 0.1

@export_group("Search")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var search_enable: bool = false
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
## 不可攻击的实体的标识
@export var bans: int = 0
## 可攻击的实体场景名称
@export var whitelist := PackedStringArray()
## 不可以攻击的实体场景名称
@export var blacklist := PackedStringArray()

var ts: float = 0


func _draw() -> void:
	if Engine.is_editor_hint():
		U.draw_range_circle(self, position, min_range, max_range)
