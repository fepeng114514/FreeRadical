extends System
class_name SpriteSystem
## 精灵系统。
##
## SpriteSystem 负责处理拥有 [SpriteComponent] 精灵组件的实体的精灵。


func _on_insert(entity: Entity) -> bool:
	var sprite_c: SpriteComponent = entity.get_node_or_null(Constants.SPRITE_COMPONENT_NODE_PATH)
	if not sprite_c:
		return true
		
	entity.play_animation(entity.config.idle_animation, &"idle", true)
		
	return true
