extends System
class_name TimeSystem
## 时间系统。
##
## TimeSystem 负责处理的时间的更新，包括帧率等。


func _on_update(delta: float) -> void:
	TimeManager.tick_time_stamp += delta
	TimeManager.tick += 1
	TimeManager.frame_length = delta
	TimeManager.fps = Engine.get_frames_per_second()
