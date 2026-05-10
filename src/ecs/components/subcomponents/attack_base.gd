extends Node2D
class_name Attackbase
## 攻击节点基类
##
## Attackbase 是所有攻击节点的基类，提供了攻击的基本属性和功能。


## 攻击标识
@export var flags: int = 0
## 冷却时间
@export var cooldown: float = 1
## 是否禁用
@export var disabled: bool = false
## 攻击概率
@export var chance: float = 1
## 攻击延迟
@export var delay: float = 0
## 攻击动画数据
@export var animation: AnimationGroup = null
## 攻击音效数据
@export var sfx: AudioGroup = null
## 实体组冷却偏移
@export var group_cooldown_offset: float = 0.1
## 是否禁用实体组冷却
@export var group_cooldown_disabled: bool = false

@export_group("Limit")
## 不可攻击的实体的标识
@export var bans: int = 0
## 可攻击的实体场景名称
@export var whitelist := PackedStringArray()
## 不可以攻击的实体场景名称
@export var blacklist := PackedStringArray()

## 时间戳
var ts: float = 0


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"damage_type":
			property.hint_string = "mask_enum:DamageType"
		"damage_flags":
			property.hint_string = "mask_enum:DamageFlag"
		"flags":
			property.hint_string = "mask_enum:Flag"
		"bans":
			property.hint_string = "mask_enum:Flag"
