extends Button


@export_file("*.tscn") var wave_editor_scene_path: String = ""


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	ChangeSceneManager.enter_scene(wave_editor_scene_path)
