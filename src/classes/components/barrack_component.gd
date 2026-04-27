@tool
extends Node2D
class_name BarrackComponent
## 兵营组件
##
## BarrackComponent 可以使实体生成士兵并管理士兵列表


## 最小集结范围
@export var rally_min_range: float = 0:
	set(value):
		rally_min_range = value
		queue_redraw()
## 最大集结范围
@export var rally_max_range: float = 300:
	set(value):
		rally_max_range = value
		queue_redraw()
## 集结点位置
@export var rally_pos := Vector2.ZERO:
	set(value):
		rally_pos = value
		queue_redraw()
## 集结点半径
@export var rally_radius: float = 30
## 士兵场景名称
@export var soldier: String = ""
## 兵营生成士兵的时间间隔（秒）
@export var respawn_time: float = 10
## 最大士兵数量
@export var max_soldiers: int = 3
## 生成士兵播放的动画
@export var animation: AnimationData = null
## 生成士兵延迟
@export var delay: float = 0
## 生成士兵播放的音效
@export var sfx: AudioData = null
## 范围显示偏移
@export var show_range_offset := Vector2.ZERO:
	set(value):
		show_range_offset = value
		queue_redraw()

## 时间戳（秒）
var ts: float = 0
## 上一次士兵数量
var last_soldier_count: int = C.UNSET
var soldier_group: EntityGroup = null


func _ready() -> void:
	soldier_group = EntityGroup.new()
	add_child(soldier_group)


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	
	draw_circle(
		show_range_offset, 
		rally_min_range,
		Color(0.448, 0.506, 0.927, 0.604), 
		false,
		6
	)
	draw_circle(
		show_range_offset, 
		rally_max_range,
		Color(0.448, 0.506, 0.927, 0.604), 
		false,
		6
	)
	
	draw_circle(
		rally_pos,
		9,
		Color(0.486, 0.294, 1.0, 1.0), 
		true
	)


func new_rally(pos: Vector2) -> void:
	rally_pos = pos
	
	for i: int in soldier_group.get_child_count():
		var s: Entity = soldier_group.get_child(i)
		var s_rally_c: RallyComponent = s.get_node_or_null(C.CN_RALLY)
		s_rally_c.new_rally(pos)
		s_rally_c.rally_formation_position(max_soldiers, i)
