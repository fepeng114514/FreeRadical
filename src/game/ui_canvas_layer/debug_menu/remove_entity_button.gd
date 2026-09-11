extends Button


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	var target: Entity = SelectManager.selected_entity
	if not target:
		return

	ECSEntityManager.queue_remove_entity(target)
