@tool
@abstract
@icon("res://assets/dpi_textures/at-icons/node2d/jigsaw_piece.svg")
extends Node2D
class_name Component
## 组件基类。
##
## 组件用于存储实体的属性和基础工具方法。


@onready var parent := get_parent()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	
	DebugManager.draw_state_changed.connect(_on_draw_state_changed)
	child_order_changed.connect(_on_child_order_changed)
	

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = NodeConfigManager.get_common_configuration_warnings(self)
	
	return warnings


func _on_draw_state_changed(_draw_type: DebugManager.DrawType) -> void:
	queue_redraw()


func _on_config_changed() -> void:
	queue_redraw()


func _on_child_order_changed() -> void:
	parent = get_parent()
	update_configuration_warnings()
