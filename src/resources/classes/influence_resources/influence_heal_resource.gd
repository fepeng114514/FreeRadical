@tool
extends InfluenceResource
class_name InfluenceHealResource


#region 治疗
## 治疗值
@export var heal_value: float = 0
## 治疗类型
@export var heal_type: HealthComponent.HealType = HealthComponent.HealType.ADD
#endregion


func _take(_source: Entity, target: Entity) -> void:
	var t_health_c: HealthComponent = target.get_node_or_null(C.CN_HEALTH)
	t_health_c.heal(heal_value, heal_type)
