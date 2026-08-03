extends VBoxContainer


@export var pointer: Control = null


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		pointer.offset_transform_position.x = event.position.x
