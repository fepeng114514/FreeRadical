extends ConfirmationDialog


@export_file() var main_scene_path: String = ""


func _ready() -> void:
	confirmed.connect(_on_confirmed)


func _on_confirmed() -> void:
	ChangeSceneMgr.enter_scene(main_scene_path)
