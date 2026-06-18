extends ConfirmationDialog


func _ready() -> void:
	confirmed.connect(_on_confirmed)


func _on_confirmed() -> void:
	get_tree().quit()
