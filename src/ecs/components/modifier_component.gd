extends Node
class_name ModifierComponent
## 状态效果组件
##
## ModifierComponent 可以使实体持续对其所有者造成影响


## 状态效果类型
@export var mod_type: int = C.ModType.NONE

@export_group("Cycle")
## 周期时间
@export var cycle_time: float = 1
## 最大周期
@export var max_cycle: int = C.UNSET
## 属性修改器列表
@export var property_modifier_list: Array[PropertyModifier] = []
## 伤害/治疗/范围伤害 统一资源
@export var influence: InfluenceResource = null

@export_group("Same Process")
## 是否允许相同状态效果叠加
@export var allow_same: bool = false
## 相同状态效果是否仅重置持续时间
@export var reset_same: bool = true
## 相同状态效果是否替换相同的状态效果
@export var replace_same: bool = false
## 相同状态效果是否叠加持续时间
@export var overlay_duration_same: bool = false
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
