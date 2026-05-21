@tool
extends InfluenceResource
class_name InfluenceDamageResource


#region 基础伤害
## 最小伤害
@export var damage_min: float = 0
## 最大伤害
@export var damage_max: float = 0
## 伤害类型
@export var damage_type: int = C.DamageType.PHYSICAL
## 伤害标识
@export var damage_flags: int = 0
## 伤害是否随距离衰减
@export var damage_falloff_enabled: bool = false
#endregion


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"damage_type":
			property.hint_string = "mask_enum:DamageType"
		"damage_flags":
			property.hint_string = "mask_enum:DamageFlag"


func _take(source: Entity, target: Entity) -> void:
	var d := Damage.new()
	d.target_id = target.id
	d.source_id = source.id
	d.source_name = source.scene_name

	var value: float = d.get_random_value(damage_min, damage_max)

	if damage_falloff_enabled:
		value *= U.dist_factor_inside_radius(
			source.global_position, 
			target.global_position, 
			search.max_radius,
			search.min_radius
		)
	d.value = value
	d.damage_type = damage_type
	d.damage_flags = damage_flags
	d.insert_damage()
