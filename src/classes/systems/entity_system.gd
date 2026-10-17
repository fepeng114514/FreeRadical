extends System
class_name EntitySystem
## 实体系统。
##
## [EntitySystem] 负责处理实体。


func _on_remove(entity: Entity) -> bool:
	for modifier_id: int in entity.has_modifier_ids:
		var modifier: Entity = EntityManager.get_entity_by_id(modifier_id)
		EntityManager.queue_remove_entity(modifier)

	for aura_id: int in entity.has_aura_ids:
		var aura: Entity = EntityManager.get_entity_by_id(aura_id)
		EntityManager.queue_remove_entity(aura)

	return true