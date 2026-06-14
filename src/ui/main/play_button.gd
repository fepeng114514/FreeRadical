extends Button


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	LevelMgr.enter_level(1)
	#get_tree().change_scene_to_file(
		#"res://ui/map/map.tscn"
	#)
