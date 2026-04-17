extends Node2D
class_name Attackbase
## 攻击节点基类
##
## Attackbase 是所有攻击节点的基类，提供了攻击的基本属性和功能。


@export_group("Limit")
## 攻击标识
@export var flags: int = 0
## 不可攻击的实体的标识
@export var bans: int = 0
## 可攻击的实体场景名称
@export var whitelist: Array[String] = []
## 不可以攻击的实体场景名称
@export var blacklist: Array[String] = []

## 时间戳
var ts: float = 0


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"flags":
			property.hint_string = "mask_enum:Flag"
		"bans":
			property.hint_string = "mask_enum:Flag"
