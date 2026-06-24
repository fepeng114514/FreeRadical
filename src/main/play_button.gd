extends Button


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	LoaderMgr.enter_scene(
		"res://map/map.tscn"
	)
