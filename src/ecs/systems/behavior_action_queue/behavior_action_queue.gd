extends RefCounted
class_name BehaviorActionQueue
## 行为动作队列类
##
## 用于定义实体的行为动作队列，包括延迟执行、等待动画、调用函数等功能。


var queue: Array[BehaviorAction] = []


## 等待时间动作
func wait(time: float) -> void:
	var action := BehaviorActionWait.new()
	action.wait_time = time
	queue.append(action)


## 等待动画动作
func wait_anim(animation_group: AnimationGroup) -> void:
	var action := BehaviorActionWaitAnimation.new()
	action.animation_group = animation_group
	queue.append(action)


## 调用函数动作
func call_fn(called: Callable) -> void:
	var action := BehaviorActionCall.new()
	action.called = called
	queue.append(action)


## 清空队列
func clear() -> void:
	queue.clear()
