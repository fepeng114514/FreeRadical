@tool
extends TextureButtonLabel


@export_file("*.tscn") var map_scene_path: String = ""


func _ready() -> void:
	texture_button.pressed.connect(_on_pressed)


func _on_pressed() -> void:
	ChangeSceneMgr.enter_scene(map_scene_path)
	
