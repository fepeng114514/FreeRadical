extends Node2D
class_name EntityWorld
## 实体世界。
## 
## [EntityWorld] 是所有非子实体的实体都会被添加到的节点。


func _ready() -> void:
	for entity: Entity in get_children():
		EntityManager.setup_entity(entity)
		EntityManager.queue_insert_entity(entity)

	EntityManager.register_entity_world(self)
