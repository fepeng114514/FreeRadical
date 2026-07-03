@tool
extends Component
class_name SpriteComponent
## 精灵组件。
##
## SpriteComponent 可以使实体拥有显示精灵的能力，精灵以 [Sprite] 或 [AnimatedSprite2D] 子节点的形式存在。


## 精灵名称。
@export var sprite_name: String = ""

@export_group("Sync Animation")
## 是否所有者同步播放动画。
@export var sync_source: bool = false
## 同步动画组数据。
@export var sync_animations: SyncAnimationsData = null


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
		
	if not get_children():
		warnings.append("请至少增加一个 AnimatedSprite2D、Sprite2D、SpriteGroup 节点")
		
	return warnings
