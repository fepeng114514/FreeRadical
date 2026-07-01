extends Node
## 波次管理器
## 
## 负责管理波次与相关操作。


@warning_ignore_start("unused_signal")
## 第一次释放波次信号。
signal first_release_wave
## 释放波次信号。
signal release_wave(wave_idx: int)
## 开始波次计时信号。
signal start_wave_timer(wave_idx: int)
@warning_ignore_restore("unused_signal")


## 波次组引用。
var wave_group: WaveGroup = null
## 波次生成器引用。
var wave_spawner: Entity = null
## 是否等待第一次释放波次。
var is_wait_first_release_wave: bool = false
## 是否跳过波次计时。
var is_release_wave: bool = false
## 当前波次。
var current_wave_idx: int = 0
## 波次是否释放完毕。
var waves_finished: bool = false
## 是否是第一次释放波次。
var is_first_release_wave: bool = true
## 是否跳过波次计时。
var is_skip_wave: bool = false


func _clear() -> void:
	wave_group = null
	wave_spawner = null
	is_wait_first_release_wave = false
	is_release_wave = false
	current_wave_idx = 0
	waves_finished = false
	is_first_release_wave = true
	is_skip_wave = false