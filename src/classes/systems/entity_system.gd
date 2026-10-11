extends System
class_name EntitySystem
## 实体系统。
##
## EntitySystem 负责处理实体的回调与更新。


func _on_remove(entity: Entity) -> bool:
	entity.clear_has_mod_list()
	entity.clear_has_aura_list()

	return true


func _on_update(_delta: float) -> void:
	for entity: Entity in EntityManager.get_valid_entities():
		if entity.state & Entity.State.DEAD or entity.is_waiting():
			continue
			
		_update_entity(entity)
		
	for entity: Entity in EntityManager.get_valid_entities():
		if entity.is_first_update:
			entity.is_first_update = false
		
		
## 更新实体。
func _update_entity(entity: Entity) -> void:
	if entity.is_first_update:
		AudioManager.play_sfx(entity.config.spawn_sfx)
		var animated_sprite_c: AnimatedSpriteComponent = entity.get_node_or_null(Constants.ANIMATED_SPRITE_COMPONENT_NODE_PATH)
		var spawn_animation: AnimationGroup = animated_sprite_c.config.spawn_animation
		if spawn_animation:
			animated_sprite_c.play_animation(entity, spawn_animation)
			if await animated_sprite_c.y_wait_animation(entity, spawn_animation):
				return