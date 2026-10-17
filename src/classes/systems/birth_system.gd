extends System
class_name BirthSystem
## 出生系统。
##
## [BirthSystem] 负责处理拥有 [BirthComponent] 的实体。


func _on_first_update(entity: Entity) -> void:
	var birth_c: BirthComponent = entity.get_node_or_null(Constants.BIRTH_COMPONENT_NODE_PATH)
	if not birth_c:
		return

	AudioManager.play_sfx(birth_c.config.birth_sfx)
	var animated_sprite_c: AnimatedSpriteComponent = entity.get_node_or_null(Constants.ANIMATED_SPRITE_COMPONENT_NODE_PATH)
	var birth_animation: FacingAnimationSet = birth_c.config.birth_animation
	if not birth_animation:
		return

	animated_sprite_c.play_animation(entity, birth_animation)
	await animated_sprite_c.y_wait_animation(entity, birth_animation)

	animated_sprite_c.play_idle_animation(entity)
