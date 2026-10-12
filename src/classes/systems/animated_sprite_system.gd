extends System
class_name AnimatedSpriteSystem
## 动画精灵系统。
##
## [AnimatedSpriteSystem] 负责处理拥有 [AnimatedSpriteComponent] 的实体。


func _on_insert(entity: Entity) -> bool:
	var animated_sprite_c: AnimatedSpriteComponent = entity.get_node_or_null(Constants.ANIMATED_SPRITE_COMPONENT_NODE_PATH)
	if not animated_sprite_c:
		return true
		
	animated_sprite_c.play_idle_animation(entity, true)
		
	return true
