extends CanvasLayer
class_name SettingCanvasLayer


@export var animation_player: AnimationPlayer = null


func _ready() -> void:
	visible = false


func show_setting() -> void:
	visible = true
	
	animation_player.play("show")


func hide_setting() -> void:
	animation_player.play("hide")
	
	await animation_player.animation_finished
	visible = false


func _on_map_ui_canvas_layer_open_setting() -> void:
	pass # Replace with function body.
