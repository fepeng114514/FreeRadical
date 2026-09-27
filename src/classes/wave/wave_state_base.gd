extends Resource
class_name WaveStateBase


var is_first_getted: bool = true
var is_first_elapsed_time: bool = true
var time_stamp: float = 0.0


func set_or_update_time_stamp() -> void:
    if is_first_getted:
        time_stamp = TimeManager.tick_time_stamp
        is_first_getted = false
    else:
        time_stamp += TimeManager.frame_length


func is_elapsed_time(duration: float) -> bool:
    return TimeManager.tick_time_stamp - time_stamp >= duration
