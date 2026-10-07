extends Resource
class_name WaveBase


## 是否需要重置时间戳。
var need_set_time_stamp: bool = true
## 是否是第一次获取波次状态。
var is_first_getted: bool = true
## 是否是第一次计算波次间隔时间。
var is_first_elapsed_time: bool = true
## 时间戳。
var time_stamp: float = 0.0


func _init() -> void:
	resource_local_to_scene = true


func try_set_time_stamp() -> void:
	if need_set_time_stamp:
		time_stamp = TimeManager.tick_time_stamp
		need_set_time_stamp = false


func is_elapsed_time(duration: float) -> bool:
	return TimeManager.tick_time_stamp - time_stamp >= duration
