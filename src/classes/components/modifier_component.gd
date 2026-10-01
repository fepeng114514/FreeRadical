@tool
extends Component
class_name ModifierComponent
## 状态效果组件。
##
## ModifierComponent 可以使实体持续对其所有者造成影响，例如增加属性值、减少属性值、增加移动速度等。


## 状态效果类型枚举。
enum Type {
	## 状态效果类型: 无。
	NONE = 0,
	## 状态效果类型: 毒。
	POISON = 1,
	## 状态效果类型: 火。
	LAVA = 1 << 1,
	## 状态效果类型: 流血。
	BLEED = 1 << 2,
	## 状态效果类型: 冻结。
	FREEZE = 1 << 3,
	## 状态效果类型: 眩晕。
	STUN = 1 << 4,
}


@export var config: ModifierComponentNodeConfig = null:
	set(v): 
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()

## 时间戳。
var time_stamp: float = 0.0
## 当前周期数。
var curren_cycle: int = 0


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"mod_type":
			property.hint_string = "mask_check(%s)" % Type