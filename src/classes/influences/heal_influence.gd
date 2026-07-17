@tool
extends Influence
class_name HealInfluence
## 治疗影响资源，用于对目标造成伤害或治愈目标。
##
## HealInfluence 用于定义如何治疗目标实体。


## 治疗类型枚举。
enum HealType {
	## 治疗类型：加法。
	ADD, 
	## 治疗类型：当前血量百分比加法。
	HP_ADD_PERCENT, 
	## 治疗类型：最大血量百分比加法。
	HP_MAX_ADD_PERCENT, 
	## 治疗类型：乘法。
	MULTIPLY,
}


## 治疗类型。
@export var heal_type: HealType = HealType.ADD


func _take(source: Entity, target: Entity, _is_area: bool) -> void:
	var health_c: HealthComponent = target.get_node_or_null(C.CN_HEALTH)
	var heal_value: float = get_value(source, target)

	match heal_type:
		HealType.ADD:
			health_c.hp += heal_value
		HealType.HP_ADD_PERCENT:
			health_c.hp += health_c.hp * heal_value
		HealType.HP_MAX_ADD_PERCENT:
			health_c.hp_max += health_c.hp_max * heal_value
		HealType.MULTIPLY:
			health_c.hp *= heal_value
