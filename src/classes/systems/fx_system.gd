extends System
class_name FXSystem
## 特效系统。
##
## FXSystem 负责处理拥有 [FXComponent] 特效组件的实体。


func _on_insert(entity: Entity) -> bool:
	var fx_c: FXComponent = entity.get_node_or_null(Constants.FX_COMPONENT_NODE_PATH)
	if not fx_c:
		return true
		
	_play_animation(entity)
		
	return true


func _play_animation(entity: Entity) -> void:
	var animated_sprite_c: AnimatedSpriteComponent = entity.get_node_or_null(Constants.ANIMATED_SPRITE_COMPONENT_NODE_PATH)
		
	if await animated_sprite_c.y_wait_animation(entity, entity.config.idle_animation):
		return

	EntityManager.queue_remove_entity(entity)
