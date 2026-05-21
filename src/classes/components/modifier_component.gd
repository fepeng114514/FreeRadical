extends Node
class_name ModifierComponent
## 状态效果组件
##
## ModifierComponent 可以使实体持续对其所有者造成影响


@export_group("Cycle")
## 周期时间
@export var cycle_time: float = 1
## 最大周期
@export var max_cycle: int = C.UNSET
## 属性修改器列表
@export var property_modifier_list: Array[PropertyModifier] = []
## 伤害/治疗/范围伤害 统一资源
@export var influence: InfluenceResource = null
@export var same_process: SameProcessResource = null
## 是否移除被禁止的状态效果
@export var remove_banned: bool = true

## 时间戳
var ts: float = 0
## 当前周期数
var curren_cycle: int = 0


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"mod_type":
			property.hint_string = "mask_enum:ModType"
