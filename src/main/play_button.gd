extends Button


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	ChangeSceneMgr.enter_scene(
		"res://map/map.tscn"
	)
