@tool
extends NodeConfig
class_name WaveSpawnerComponentNodeConfig
## 波次生成器组件节点配置资源。
##
## [WaveSpawnerComponentNodeConfig] 用于存储 [WaveSpawnerComponent] 的可配置数据。


## 波次组。
@export var wave_group: WaveGroup = null:
	set(v):
		wave_group = v
		emit_changed()
## 波次间隔开始音效。
@export var wave_timer_start_sfx: AudioGroup = null
## 波次间隔结束音效。
@export var wave_timer_finish_sfx: AudioGroup = null
