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

## 是否跟随目标。
@export var track_target: bool = true
## 属性修改器列表。
@export var property_modifier_list: Array[PropertyModifier] = []
## 相同处理资源。
@export var same_process: SameProcessResource = null
## 是否移除被禁止的状态效果。
@export var remove_banned: bool = true

## 影响资源，用于对目标造成伤害或治愈目标。
@export var influence: Influence = null

@export_group("Cycle")
## 是否启用周期影响。
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var cycle_enabled: bool = false
## 周期时间。
@export var cycle_time: float = 1.0
## 最大周期。
@export var max_cycle: int = Constants.UNSET

## 时间戳。
var ts: float = 0.0
## 当前周期数。
var curren_cycle: int = 0


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"mod_type":
			property.hint_string = "mask_check(%s)" % Type