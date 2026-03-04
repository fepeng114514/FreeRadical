extends Node2D

var clicked_global_position := Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		clicked_global_position = get_global_mouse_position()
		
