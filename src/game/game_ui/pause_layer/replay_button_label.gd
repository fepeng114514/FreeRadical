@tool
extends TextureButtonLabel


func _ready() -> void:
	texture_button.pressed.connect(_on_pressed)


func _on_pressed() -> void:
	get_tree().reload_current_scene()
	
