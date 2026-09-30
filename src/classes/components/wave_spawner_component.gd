@tool
extends Component
class_name WaveSpawnerComponent
## 波次生成器组件。
##
## WaveSpawnerComponent 可以使实体生成波次数据中的实体。


enum SUB_WAVE_STATE_FLAGS {
	DONE,
	SPAWNING,
}


@export var config: WaveSpawnerComponentNodeConfig = null


## 波次组。
@export var wave_group: WaveGroup = null:
	set(v):
		wave_group = v
		update_configuration_warnings()
## 波次间隔开始音效。
@export var wave_timer_start_sfx: AudioGroup = null
## 波次间隔结束音效。
@export var wave_timer_finish_sfx: AudioGroup = null

## 是否所有波次都释放完毕。
var waves_finished: bool = false
