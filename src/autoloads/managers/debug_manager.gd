@tool
extends Node
## 调试管理器。


## 绘制类型。
enum DrawType {
	PATHWAY,
	OFFSET,
	RANGE,
	POINT,
}


@warning_ignore_start("unused_signal")
## 任意绘制状态发生更改时发出。
signal draw_state_changed(draw_type: DrawType)
@warning_ignore_restore("unused_signal")


## 是否启用绘制路径。
var draw_pathway_enabled: bool = false:
	set(v):
		draw_pathway_enabled = v
		draw_state_changed.emit(DrawType.PATHWAY)
## 是否启用绘制偏移。
var draw_offset_enabled: bool = false:
	set(v):
		draw_offset_enabled = v
		draw_state_changed.emit(DrawType.OFFSET)
## 是否启用绘制范围。
var draw_range_enabled: bool = false:
	set(v):
		draw_range_enabled = v
		draw_state_changed.emit(DrawType.RANGE)
## 是否启用绘制点位。
var draw_point_enabled: bool = false:
	set(v):
		draw_point_enabled = v
		draw_state_changed.emit(DrawType.POINT)


func _ready() -> void:
	if Engine.is_editor_hint():
		draw_pathway_enabled = true
		draw_offset_enabled = true
		draw_range_enabled = true
		draw_point_enabled = true
