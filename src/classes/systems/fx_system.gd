extends System
class_name FXSystem
## 特效系统
##
## 处理拥有 [FXComponent] 特效组件的实体


func _on_insert(e: Entity) -> bool:
	var fx_c: FXComponent = e.get_node_or_null(C.CN_FX)
	if not fx_c:
		return true
		
	_play_animation(e)
		
	return true


func _play_animation(e: Entity) -> void:
	if await e.y_wait_animation(e.idle_animation):
		return

	e.remove_entity()
