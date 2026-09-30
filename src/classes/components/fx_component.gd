@tool
extends Component
class_name FXComponent
## 特效组件。
##
## FXComponent 可以使实体拥有特效的能力，特效以 [FX] 子节点的形式存在。


@export var config: FXComponentNodeConfig = null:
	set(v):
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()

## 是否是一次性特效。
@export var is_once: bool = true