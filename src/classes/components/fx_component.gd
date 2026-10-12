@tool
extends Component
class_name FXComponent
## 特效组件。
##
## [FXComponent] 可以让实体显示特效。


@export var config: FXComponentNodeConfig = null:
	set(v):
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()