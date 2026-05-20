extends System
class_name BehaviorQueueSystem
## 行为队列系统
##
## 处理所有实体的行为队列更新


func _on_update(delta: float) -> void:
	for e: Entity in EntityMgr.get_valid_entities():
		var new_queue: Array[BehaviorAction] = []
		var waiting: bool = false

		for action: BehaviorAction in e.behavior_action_queue.queue:
			if waiting:
				new_queue.append(action)
				continue

			if action is BehaviorActionWaitAnimation:
				if not action.is_initialized:
					var animation_group: AnimationGroup = action.animation_group
					action.wait_time = e.get_animation_remaining_time(animation_group)
					action.is_initialized = true

			if action is BehaviorActionWait:
				action.elapsed += delta
				if action.elapsed < action.wait_time:
					e.set_waiting()
					new_queue.append(action)
					waiting = true
				else:
					e.clear_waiting()
					waiting = false
			elif action is BehaviorActionCall:
				action.called.call()
			
		e.behavior_action_queue.queue = new_queue
