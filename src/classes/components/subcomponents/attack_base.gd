extends Node2D
class_name Attackbase
## 攻击节点基类
##
## Attackbase 是所有攻击节点的基类，提供了攻击的基本属性和功能。


@export_group("Limit")
## 攻击标识
@export var flags: Array[C.Flag] = []:
	set(value): 
		flags = value
		flag_bits = U.merge_flags(value)
## 不可攻击的实体的标识
@export var bans: Array[C.Flag] = []:
	set(value): 
		bans = value
		ban_bits = U.merge_flags(value)
## 可攻击的实体场景名称
@export var whitelist: Array[String] = []
## 不可以攻击的实体场景名称
@export var blacklist: Array[String] = []

## 二进制的攻击标识
var flag_bits: int = 0
## 二进制的不可攻击的实体的标识
var ban_bits: int = 0
## 时间戳
var ts: float = 0
