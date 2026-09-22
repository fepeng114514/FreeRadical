extends Node2D
class_name ECSEntityWorld
## 实体世界，所有实体都会被添加到这个节点下。


func _ready() -> void:
	for entity: ECSEntity in get_children():
		ECSEntityManager.setup_entity(entity)
		ECSEntityManager.queue_insert_entity(entity)

	ECSEntityManager.register_entity_world(self)
