extends ConfirmationDialog


func _ready() -> void:
	confirmed.connect(_on_confirmed)


func _on_confirmed() -> void:
	LoaderMgr.enter_scene(
		"res://main/main.tscn"
	)
