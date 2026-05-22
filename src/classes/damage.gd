class_name Damage
## 伤害类


## 目标实体 ID
var target_id: int = C.UNSET
## 来源实体 ID
var source_id: int = C.UNSET
## 伤害值
var value: float = 0
## 伤害类型
var damage_type: int = C.DamageType.PHYSICAL
## 伤害因子
var damage_factor: float = 1
## 伤害标识
var damage_flags: int = C.DamageFlag.NONE
## 来源实体名称
var source_name: StringName = &""
## 来源实体技能名称
var source_skill_type: Skill.Type = Skill.Type.NONE
## 是否为区域伤害
var is_area: bool = false


func insert_damage() -> void:
	SystemMgr.damage_queue.append(self)


func get_random_value(damage_min: float, damage_max: float) -> float:
	return randf_range(damage_min, damage_max)
