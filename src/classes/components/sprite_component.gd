@tool
extends Component
class_name SpriteComponent
## 精灵组件。
##
## SpriteComponent 可以使实体拥有显示精灵的能力，精灵以 [Sprite] 或 [AnimatedSprite2D] 子节点的形式存在。


@export var config: SpriteComponentNodeConfig = null:
	set(v):
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()


func _ready() -> void:
	super()
	
	show_behind_parent = true
	process_mode = Node.PROCESS_MODE_INHERIT
