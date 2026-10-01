extends System
class_name FXSystem
## 特效系统。
##
## FXSystem 负责处理拥有 [FXComponent] 特效组件的实体


func _on_insert(entity: Entity) -> bool:
	var fx_c: FXComponent = entity.get_node_or_null(Constants.CN_FX)
	if not fx_c:
		return true
		
	_play_animation(entity)
		
	return true


func _play_animation(entity: Entity) -> void:
	if await entity.y_wait_animation(entity.config.idle_animation):
		return

	EntityManager.queue_remove_entity(entity)
