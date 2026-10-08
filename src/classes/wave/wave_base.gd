extends Resource
class_name WaveBase


## 是否需要重置时间戳。
var need_set_timestamp: bool = true
## 是否是第一次获取波次状态。
var is_first_getted: bool = true
## 是否是第一次计算波次间隔时间。
var is_first_elapsed_time: bool = true
## 时间戳。
var timestamp: float = 0.0


func try_set_timestamp() -> void:
	if need_set_timestamp:
		timestamp = TimeManager.tick_timestamp
		need_set_timestamp = false


func is_elapsed_time(duration: float) -> bool:
	return TimeManager.tick_timestamp - timestamp >= duration
