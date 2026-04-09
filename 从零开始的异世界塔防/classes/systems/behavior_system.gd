extends System
class_name BehaviorSystem
## 行为系统
##
## 处理其下的子行为的调用


var _behaviors: Array[Behavior] = []
var _update_cbs: Array[Callable] = []
var _return_true_cbs: Array[Callable] = []
var _return_false_cbs: Array[Callable] = []
var _insert_cbs: Array[Callable] = []
var _remove_cbs: Array[Callable] = []


func _ready() -> void:
	for child: Behavior in get_children():
		_behaviors.append(child)
		_update_cbs.append(child.get("_on_update"))
		_return_true_cbs.append(child.get("_on_return_true"))
		_return_false_cbs.append(child.get("_on_return_false"))
		_insert_cbs.append(child.get("_on_insert"))
		_remove_cbs.append(child.get("_on_remove"))


func _on_insert(e: Entity) -> bool:
	for insert_fn: Callable in _insert_cbs:
		if not insert_fn.call(e):
			return false

	return true


func _on_remove(e: Entity) -> bool:
	for remove_fn: Callable in _remove_cbs:
		if not remove_fn.call(e):
			return false

	return true
	
	
func _on_update(_delta: float) -> void:
	for e: Entity in EntityMgr.get_valid_entities():
		if e.is_waiting():
			continue
		
		for i in _behaviors.size():
			if not _update_cbs[i].call(e):
				continue

			for return_true_fn: Callable in _return_true_cbs:
				return_true_fn.call(e, _behaviors[i])

			break

		for return_false_fn: Callable in _return_false_cbs:
			return_false_fn.call(e)

		if not e.has_c(C.CN_SPRITE):
			continue
			
		e.play_idle_animation()
			