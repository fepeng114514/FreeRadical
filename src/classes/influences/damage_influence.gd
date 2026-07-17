@tool
extends Influence
class_name DamageInfluence
## 伤害影响资源，用于对目标造成伤害或治愈目标。
##
## DamageInfluence 用于定义如何对目标实体造成伤害。


## 伤害类型。
@export var damage_type: int = C.DamageType.PHYSICAL
## 伤害标识。
@export var damage_flags: int = 0


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"damage_type":
			property.hint_string = "mask_enum:DamageType"
		"damage_flags":
			property.hint_string = "mask_enum:DamageFlag"


func _take(source: Entity, target: Entity, is_area: bool) -> void:
	var d := Damage.new()
	d.target_id = target.id
	d.source_id = source.id
	d.source_name = source.name
	d.is_area = is_area
	d.value = get_value(source, target)
	d.damage_type = damage_type
	d.damage_flags = damage_flags
	d.insert_damage()


func get_damage_value() -> float:
	var value: float = randf_range(min_value, max_value)

	return value
