@tool
extends Component
class_name DurationComponent
## 持续时间组件。
##
## DurationComponent 可以使实体在持续特定时间后自动移除。


## 配置。
@export var config: DurationComponentNodeConfig = null:
	set(v): 
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()

## 持续时间戳。
var duration_timestamp: float = 0.0
