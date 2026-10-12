@tool
extends Component
class_name BirthComponent
## 出生组件。
##
## [BirthComponent] 可以在实体出生时执行一些操作。


@export var config: BirthComponentNodeConfig = null:
	set(v): 
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()
