extends Node2D


func _ready() -> void:
	for entity: ECSEntity in get_children():
		ECSEntityManager.setup_entity(entity)
		ECSEntityManager.queue_insert_entity(entity)
