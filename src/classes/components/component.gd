@abstract
extends ECSComponent
class_name Component
## 组件基类。
##
## 组件用于存储实体的属性和基础工具方法。


func _ready() -> void:
	DebugManager.draw_state_changed.connect(_on_draw_state_changed)
	
	process_mode = Node.PROCESS_MODE_DISABLED
	

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = NodeConfigManager.get_common_configuration_warnings(self)
	
	return warnings


func _on_draw_state_changed(_draw_type: DebugManager.DrawType) -> void:
	queue_redraw()


func _on_config_changed() -> void:
	queue_redraw()
