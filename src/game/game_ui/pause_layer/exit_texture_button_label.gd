@tool
extends TextureButtonLabel


func _ready() -> void:
	texture_button.pressed.connect(_on_pressed)


func _on_pressed() -> void:
	LoaderMgr.enter_scene(
		"res://map/map.tscn"
	)
	
