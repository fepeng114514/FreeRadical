extends ECSSystem
class_name EntitySystem
## 实体系统。
##
## EntitySystem 负责处理实体的回调与更新。


func _on_insert(entity: ECSEntity) -> bool:
	entity = entity as Entity

	entity.insert_ts = TimeManager.tick_ts

	return entity._on_insert()
	

func _on_remove(entity: ECSEntity) -> bool:
	entity = entity as Entity

	if not entity._on_remove():
		return false
	
	entity.clear_has_mod_list()
	entity.clear_has_aura_list()

	return true


func _on_update(delta: float) -> void:
	for entity: Entity in ECSEntityManager.get_valid_entities():
		if entity.state & Entity.State.DEAD or entity.is_waiting():
			continue

		if Utils.is_valid_number(entity.duration) and TimeManager.has_elapsed(entity.insert_ts, entity.duration):
			ECSEntityManager.queue_remove_entity(entity)
			continue
			
		_update_entity(entity, delta)
		
	for entity: Entity in ECSEntityManager.get_valid_entities():
		if entity.is_first_update:
			entity.is_first_update = false
		
		
## 更新实体。
func _update_entity(entity: Entity, delta: float) -> void:
	if entity.is_first_update:
		entity.play_animation(entity.spawn_animation)
		AudioManager.play_sfx(entity.spawn_sfx)
		if entity.spawn_animation:
			if await entity.y_wait_animation(entity.spawn_animation):
				return
		
	entity._on_update(delta)
	
	entity.last_global_position = entity.global_position
