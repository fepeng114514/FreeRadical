extends System
class_name EntitySystem
## 实体系统。
##
## EntitySystem 负责处理实体的回调与更新。


func _on_insert(e: Entity) -> bool:
	e.insert_ts = TimeMgr.tick_ts

	return e._on_insert()
	

func _on_remove(e: Entity) -> bool:
	if not e._on_remove():
		return false
	
	e.clear_has_mod_list()
	e.clear_has_aura_list()

	return true


func _on_update(delta: float) -> void:
	var entities: Array[Entity] = EntityMgr.get_valid_entities().filter(
		func(e: Entity) -> bool:
			return not e.state & Entity.State.DEAD and not e.is_waiting()
	)
	
	for e: Entity in entities:
		if U.is_valid_number(e.duration) and TimeMgr.has_elapsed(e.insert_ts, e.duration):
			e.remove_entity()
			continue
			
		_update_entity(e, delta)
		
	for e: Entity in EntityMgr.get_valid_entities():
		if e.is_first_update:
			e.is_first_update = false
		
		
## 更新实体。
func _update_entity(e: Entity, delta: float) -> void:
	if e.is_first_update:
		e.play_animation(e.spawn_animation)
		AudioMgr.play_sfx(e.spawn_sfx)
		if e.spawn_animation:
			if await e.y_wait_animation(e.spawn_animation):
				return
		
	e._on_update(delta)
	
	e.last_position = e.global_position
