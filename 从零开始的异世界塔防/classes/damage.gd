class_name Damage
## 伤害类


## 目标实体 ID
var target_id: int = C.UNSET
## 来源实体 ID
var source_id: int = C.UNSET
## 伤害值
var value: float = 0
## 最小伤害
var damage_min: float = 0
## 最大伤害
var damage_max: float = 0
## 伤害类型
var damage_type: C.DamageType = C.DamageType.PHYSICAL
## 伤害因子
var damage_factor: float = 1
## 伤害标识
var damage_flags: Array[C.DamageFlag] = []:
	set(value):
		damage_flags = value
		damage_flag_bits = U.merge_flags(damage_flags)
	
## 二进制的伤害标识
var damage_flag_bits: int = 0
