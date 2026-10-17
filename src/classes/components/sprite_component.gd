@tool
extends Component
class_name SpriteComponent
## 精灵组件。
##
## [SpriteComponent] 可以让实体显示 [Sprite] 节点。


@export var config: SpriteComponentNodeConfig = null:
	set(v):
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()