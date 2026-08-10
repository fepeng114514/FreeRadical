extends System
class_name BehaviorSystem
## 行为系统。
##
## BehaviorSystem 负责处理与管理行为树。


var _behavior_list: Array[Behavior] = []
## 行为的数量。
@onready var _behavior_count: int = get_child_count()


func _ready() -> void:
	for child: Behavior in get_children():
		_behavior_list.append(child)


func _on_insert(e: Entity) -> bool:
	for b: Behavior in _behavior_list:
		if not b._on_insert(e):
			return false

	return true


func _on_remove(e: Entity) -> bool:
	for b: Behavior in _behavior_list:
		if not b._on_remove(e):
			return false

	return true
	
	
func _on_update(_delta: float) -> void:
	var entities: Array[Entity] = EntityMgr.get_valid_entities().filter(
		func(e: Entity) -> bool:
			return not e.is_waiting() and not e.state & Entity.State.DEAD
	)
	
	for e: Entity in entities:
		var is_break: bool = false
		for i: int in _behavior_count:
			var b: Behavior = _behavior_list[i]
			
			if b._on_update(e):
				for skipped_i: int in range(i + 1, _behavior_count):
					var skipped_b: Behavior = _behavior_list[skipped_i]
					skipped_b._on_skip(e)
				
				is_break = true
				break
			
		if not is_break:
			if not e.get_node_or_null(C.CN_SPRITE):
				continue
				
			e.play_animation(e.idle_animation)
			
			
