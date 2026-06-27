extends Button


@export_file() var map_scene_path: String = ""


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	ChangeSceneMgr.enter_scene(map_scene_path)
