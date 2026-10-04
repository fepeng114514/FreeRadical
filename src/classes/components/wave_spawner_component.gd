@tool
extends Component
class_name WaveSpawnerComponent
## 波次生成器组件。
##
## WaveSpawnerComponent 可以使实体生成波次数据中的实体。


@export var config: WaveSpawnerComponentNodeConfig = null:
	set(v):
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()

## 待处理波次队列。
var wave_queue: Array[Wave] = []
## 是否完成生成所有波次。
var is_waves_finished: bool = false
