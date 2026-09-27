extends Node
## 波次管理器
## 
## 负责管理波次与相关操作。


@warning_ignore_start("unused_signal")
## 第一次释放波次时发出。
signal first_release_wave
## 开始波次计时时发出。
signal start_wave_timer(wave_index: int)
## 释放波次时发出。
signal release_wave(wave_index: int)
## 所有波次都释放完毕时发出。
signal waves_finished
@warning_ignore_restore("unused_signal")


## 是否等待第一次释放波次。
var need_wait_first_release_wave: bool = false
## 是否跳过波次计时。
var is_release_wave: bool = false
## 是否所有波次都释放完毕。
var is_waves_finished: bool = false

var _wave_queue: Array[WaveState] = []


## 清理波次管理器。
func cleanup() -> void:
	need_wait_first_release_wave = false
	is_release_wave = false
	is_waves_finished = false
	_wave_queue.clear()


func insert_wave(wave_state: WaveState) -> void:
	_wave_queue.append(wave_state)


func pop_front_wave() -> WaveState:
	return _wave_queue.pop_front()


func get_first_wave() -> WaveState:
	return _wave_queue[0]


func queue_size() -> int:
	return _wave_queue.size()
