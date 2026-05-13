@tool
extends Attackbase
class_name MeleeBase
## 近战攻击节点基类
##
## MeleeBase 是 [MelleComponent] 的近战攻击节点的基类，提供了近战攻击的基本属性和功能。


@export_group("Damage")
## 最小伤害
@export var damage_min: float = 0
## 最大伤害
@export var damage_max: float = 0
## 伤害类型
@export var damage_type: int = C.DamageType.PHYSICAL
## 伤害标识
@export var damage_flags: int = 0
## 击中目标给予的状态效果
@export var mods: PackedStringArray = []

@export_subgroup("Area Damage")
## 是否启用范围伤害
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var damage_area_enable: bool = false
## 最小伤害半径
@export var damage_min_radius: float = 0
## 最大伤害半径
@export var damage_max_radius: float = 0
## 最大伤害数量
@export var damage_max_count: int = C.UNSET
## 范围伤害的搜索模式
@export var damage_search_mode: C.SearchMode = C.SearchMode.ENEMY_MAX_PROGRESS
## 范围伤害是否随距离衰减
@export var damage_falloff_enabled: bool = false
## 范围伤害的圆心偏移
@export var damage_offsets: OffsetGroup = null:
	set(value):
		damage_offsets = value
		if Engine.is_editor_hint():
			U.connect_offset_group_changed(damage_offsets, _on_damage_offsets_changed)
		queue_redraw()
## 是否可以伤害重复敌人
@export var can_damage_same: bool = false


func _ready() -> void:
	if Engine.is_editor_hint():
		U.connect_offset_group_changed(damage_offsets, _on_damage_offsets_changed)


func _on_damage_offsets_changed() -> void:
	queue_redraw()


func _draw() -> void:
	if Engine.is_editor_hint():
		U.draw_offset_group(self, damage_offsets)
