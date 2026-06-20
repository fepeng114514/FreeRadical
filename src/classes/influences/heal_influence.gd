@tool
extends Influence
class_name HealInfluence
## 治疗影响资源。
##
## HealInfluence 用于定义如何治疗目标实体。


#region 治疗
## 治疗值。
@export var heal_value: float = 0.0
## 治疗类型。
@export var heal_type: HealthComponent.HealType = HealthComponent.HealType.ADD
#endregion


func _take(_source: Entity, target: Entity, _source_skill_type: Skill.Type, _is_area: bool) -> void:
	var t_health_c: HealthComponent = target.get_node_or_null(C.CN_HEALTH)
	if falloff_enabled:
		heal_value *= U.dist_factor_inside_radius(
			target.global_position, 
			target.global_position, 
			search.max_radius,
			search.min_radius
		)
	t_health_c.heal(heal_value, heal_type)
