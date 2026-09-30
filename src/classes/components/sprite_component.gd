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

@export_group("Sync Animation")
## 是否所有者同步播放动画。
@export var sync_source: bool = false
## 同步动画组数据。
@export var sync_animations: SyncAnimationsData = null


func _ready() -> void:
	super()
	
	show_behind_parent = true
	process_mode = Node.PROCESS_MODE_INHERIT
