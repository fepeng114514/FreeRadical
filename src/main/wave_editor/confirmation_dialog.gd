extends ConfirmationDialog


func _ready() -> void:
	confirmed.connect(_on_confirmed)


func _on_confirmed() -> void:
	get_tree().change_scene_to_file(
		"res://main/main.tscn"
	)
