extends System
class_name FXSystem
## 特效系统
##
## 处理拥有 [FXComponent] 特效组件的实体


func _on_insert(e: Entity) -> bool:
	var fx_c: FXComponent = e.get_node_or_null(C.CN_FX)
	if not fx_c:
		return true
		
	var baq: BehaviorActionQueue = e.behavior_action_queue
	baq.wait_anim(e.idle_animation)
	baq.call_fn(func(): e.remove_entity())
		
	return true
