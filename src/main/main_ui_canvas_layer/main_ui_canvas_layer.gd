extends CanvasLayer
class_name MainUICanvasLayer


@export var setting_canvas_layer: SettingCanvasLayer = null


func _on_setting_button_pressed() -> void:
	setting_canvas_layer.show_setting()
