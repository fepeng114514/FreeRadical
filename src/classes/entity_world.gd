extends Node2D
class_name EntityWorld
## 实体世界，所有实体都会被添加到这个节点下。


func _ready() -> void:
	for entity: Entity in get_children():
		EntityManager.setup_entity(entity)
		EntityManager.queue_insert_entity(entity)

	EntityManager.register_entity_world(self)
