extends Node
## 波次管理器。
## 
## [WaveManager] 负责管理波次与相关操作。


@warning_ignore_start("unused_signal")
## 第一波释放时发出。
signal first_wave_released
## 开始波次计时时发出。
signal wave_timer_started(wave_index: int)
## 波次计时进度更新时发出。
signal wave_timer_progress(progress: float)
## 波次计时结束时发出。
signal wave_timer_finished
## 释放波次时发出。
signal wave_released(wave_index: int)
## 所有波次都释放完毕时发出。
signal waves_finished
@warning_ignore_restore("unused_signal")

## 波次组引用。
var wave_group: WaveGroup = null
## 当前波次索引。
var current_wave_index: int = Constants.UNSET
## 当前波次会生成怪物的路径索引数组。
var current_wave_pathway_indexes: Array[int] = []
## 是否可以触发第一波释放信号。
var can_emit_first_wave_released: bool = true
## 是否可以触发波次计时结束信号。
var can_emit_wave_timer_finished: bool = true
## 是否跳过当前波次。
var is_skip_wave: bool = false
## 是否释放波次。
var is_release_wave: bool = false
## 是否所有波次都释放完毕。
var is_waves_finished: bool = false


## 清理波次管理器。
func cleanup() -> void:
	wave_group = null
	current_wave_pathway_indexes.clear()
	can_emit_first_wave_released = true
	is_skip_wave = false
	is_release_wave = false
	is_waves_finished = false


## 获取当前波次。
func get_current_wave() -> Wave:
	return wave_group.wave_list[current_wave_index]
