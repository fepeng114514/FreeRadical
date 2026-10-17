extends Node
## 时间数据库管理器。
## 
## [TimeManager] 负责管理时间与相关操作。


## 自上次初始化后已经过的时间戳。
var tick_timestamp: float = 0.0
## 自上次初始化后已经过的帧数。
var tick: int = 0
## 帧长度，始终等于 [method Node._process] 的 [code]delta[/code]。
var frame_length: float = 0.0
## 每秒的经过的帧数，始终等于 [method Engine.get_frames_per_second]。
var fps: float = 0.0


## 清理时间管理器。
func cleanup() -> void:
	tick_timestamp = 0
	tick = 0
	frame_length = 0
	fps = 0


## 判断自指定时间戳以来是否已过了指定时长。
func has_elapsed(timestamp: float, duration: float) -> bool:
	return tick_timestamp - timestamp > duration
	

## 获取自指定时间戳以来流逝的时间。
func get_elapsed_time(timestamp: float) -> float:
	return tick_timestamp - timestamp
		
		
## 协程等待指定时长。[br][br]
## [param break_fn]: 中断函数。返回 [code]true[/code] 表示中断等待。
func y_wait(duration: float, break_fn: Callable = Callable()) -> bool:
	var timestamp: float = tick_timestamp
	while not has_elapsed(timestamp, duration):
		if break_fn.is_valid() and break_fn.call():
			return true

		await get_tree().process_frame
		
	return false
