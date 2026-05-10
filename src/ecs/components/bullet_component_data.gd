@tool
extends Resource
class_name BulletComponentData


@export_group("Damage")
## 子弹最小伤害
@export var damage_min: float = 0
## 子弹最大伤害
@export var damage_max: float = 0
## 伤害类型
@export var damage_type: int = C.DamageType.PHYSICAL
## 伤害标识
@export var damage_flags: int = 0
## 子弹携带的状态效果
@export var mods := PackedStringArray()

@export_subgroup("Area Damage")
## 是否启用范围伤害
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var damage_area_enable: bool = false
## 最小伤害半径
@export var damage_min_radius: float = 0
## 最大伤害半径
@export var damage_max_radius: float = 0
## 最大伤害数量
@export var damage_max_count: int = C.UNSET
## 范围伤害的圆心偏移
@export var damage_offset := Vector2.ZERO
## 是否可以伤害重复敌人
@export var can_damage_same: bool = false
## 范围伤害的搜索模式
@export var damage_search_mode: C.SearchMode = C.SearchMode.ENEMY_MAX_PROGRESS
## 范围伤害是否随距离衰减
@export var damage_falloff_enabled: bool = false


func _validate_property(property: Dictionary):
	match property.name:
		"damage_type":
			property.hint_string = "mask_enum:DamageType"
