extends Node
## 时间数据库管理器。
##
## 负责管理时间与相关操作。


## 自上次初始化后已经过的时间戳。
var tick_ts: float = 0.0
## 自上次初始化后已经过的帧数。
var tick: int = 0
## 帧长度，始终等于 [method Node._process] 的 delta。
var frame_length: float = 0.0
## 每秒的经过的帧数，始终等于 [method Engine.get_frames_per_second]。
var fps: float = 0.0


func _clear() -> void:
	tick_ts = 0
	tick = 0
	frame_length = 0
	fps = 0


## 判断自指定时间戳以来是否已过了指定时长。
func has_elapsed(ts: float, duration: float) -> bool:
	return tick_ts - ts > duration
	

## 获取自指定时间戳以来流逝的时间。
func get_elapsed_time(ts: float) -> float:
	return tick_ts - ts
		
		
## 协程等待指定时长，break_fn 返回 true 表示中断等待。
func y_wait(duration: float = 0.0, break_fn: Callable = Callable()) -> bool:
	if duration <= 0:
		return false

	var ts: float = tick_ts
	var is_break: bool = false
	while not has_elapsed(ts, duration):
		is_break = break_fn.call() if break_fn.is_valid() else false
		if is_break:
			break

		await get_tree().process_frame

	return is_break
		
