extends System
class_name BehaviorSystem
## 行为系统。
##
## BehaviorSystem 负责处理与管理行为树。


var _behavior_list: Array[Behavior] = []
var _behavior_list_size: int = 0


func _ready() -> void:
	for child: Behavior in get_children():
		_behavior_list.append(child)

	_behavior_list_size = _behavior_list.size()


func _on_insert(entity: Entity) -> bool:
	for behavior: Behavior in _behavior_list:
		if not behavior._on_insert(entity):
			return false

	return true


func _on_remove(entity: Entity) -> bool:
	for behavior: Behavior in _behavior_list:
		if not behavior._on_remove(entity):
			return false

	return true
	
	
func _on_update(_delta: float) -> void:
	for entity: Entity in EntityManager.get_valid_entities():
		if entity.is_waiting() or entity.state & Entity.State.DEAD:
			continue

		var is_break: bool = false
		for behavior_index: int in _behavior_list_size:
			var behavior: Behavior = _behavior_list[behavior_index]
			
			if behavior._on_update(entity):
				for skipped_index: int in range(behavior_index + 1, _behavior_list_size):
					var skipped_behavior: Behavior = _behavior_list[skipped_index]
					skipped_behavior._on_skip(entity)
				
				is_break = true
				break
			
		if not is_break:
			if not entity.get_node_or_null(Constants.CN_SPRITE):
				continue
				
			entity.play_animation(entity.config.idle_animation)
			
			
