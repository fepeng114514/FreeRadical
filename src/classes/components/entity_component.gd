@tool
extends Component
class_name EntityComponent
## 实体组件。
##
## EntityComponent 用于存储实体的数据。


@export var config: EntityComponentNodeConfig = null:
	set(v): 
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()
