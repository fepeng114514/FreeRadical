extends System
class_name EntitySystem
## 实体系统。
##
## EntitySystem 负责处理实体的回调与更新。


func _on_insert(entity: Entity) -> bool:
	entity.inserted_time_stamp = TimeManager.tick_time_stamp

	return true
	

func _on_remove(entity: Entity) -> bool:
	entity.clear_has_mod_list()
	entity.clear_has_aura_list()

	return true


func _on_update(_delta: float) -> void:
	for entity: Entity in EntityManager.get_valid_entities():
		if entity.state & Entity.State.DEAD or entity.is_waiting():
			continue

		if Utils.is_valid_number(entity.config.duration) and TimeManager.has_elapsed(entity.inserted_time_stamp, entity.config.duration):
			EntityManager.queue_remove_entity(entity)
			continue
			
		_update_entity(entity)
		
	for entity: Entity in EntityManager.get_valid_entities():
		if entity.is_first_update:
			entity.is_first_update = false
		
		
## 更新实体。
func _update_entity(entity: Entity) -> void:
	if entity.is_first_update:
		entity.play_animation(entity.config.spawn_animation)
		AudioManager.play_sfx(entity.config.spawn_sfx)
		if entity.config.spawn_animation:
			if await entity.y_wait_animation(entity.config.spawn_animation):
				return
	
	entity.last_global_position = entity.global_position
