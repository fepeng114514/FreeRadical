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


@export var config: WaveSpawnerComponentNodeConfig = null:
	set(v):
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()


## 是否所有波次都释放完毕。
var waves_finished: bool = false
