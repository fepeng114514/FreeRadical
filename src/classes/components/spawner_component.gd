@tool
extends Component
class_name SpawnerComponent
## 生成器组件。
##
## SpawnerComponent 可以使实体拥有生成其他实体的能力。
## @deprecated
## @deprecated: 未实现。


@export var config: SpawnerComponentNodeConfig = null:
	set(v):
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()

## 生成器名称。
@export var spawner_name: String = ""