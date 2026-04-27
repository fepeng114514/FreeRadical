@tool
extends Attackbase
class_name RangedBase
## 远程攻击基类
##
## RangedBase 是 [RangedComponent] 的远程攻击节点的基类，提供了远程攻击的基本属性和功能。


## 最小攻击距离
@export var min_range: float = 0
## 最大攻击距离
@export var max_range: float = 300:
	set(value):
		max_range = value
		queue_redraw()
## 范围显示偏移
@export var show_range_offset := Vector2.ZERO:
	set(value):
		show_range_offset = value
		queue_redraw()
## 冷却时间
@export var cooldown: float = 1
## 目标搜索模式
@export var search_mode: C.SearchMode = C.SearchMode.ENEMY_MAX_PROGRESS
## 子弹场景名称
@export var bullet: String = ""
## 子弹发射数量
@export var bullet_count: int = 1
## 子弹初始位置偏移
@export var bullet_offsets: OffsetData = null
## 子弹发射的角度范围，单位为度
@export_range(0, 360, 0.1, "radians_as_degrees") var bullet_angle_range: float = 0
## 子弹发射模式
@export var bullet_spawn_mode: C.BulletSpawnMode = C.BulletSpawnMode.EQUAL_INTERVAL
## 发射子弹的延迟
@export var delay: float = 0
## 攻击概率
@export var chance: float = 1
## 近战攻击时是否可以远程攻击
@export var with_melee: bool = false
## 是否禁用
@export var disabled: bool = false

@export_group("Damage")
## 子弹最小伤害
@export var damage_min: float = 0
## 子弹最大伤害
@export var damage_max: float = 0
## 伤害类型
@export var damage_type: int = C.DamageType.PHYSICAL
## 伤害标识
@export var damage_flags: int = 0
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
@export var damage_offset := Vector2.ZERO
## 是否可以伤害重复敌人
@export var can_damage_same: bool = false


func _ready() -> void:
	bullet_offsets.changed.connect(_on_offset_data_changed)


func _validate_property(property: Dictionary):
	match property.name:
		"damage_type":
			property.hint_string = "mask_enum:DamageType"
		"damage_flags":
			property.hint_string = "mask_enum:DamageFlag"


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
		
	for v: Vector2 in bullet_offsets.to_dict().values():
		if not v:
			continue
		
		draw_circle(
			v, 
			3,
			Color.GREEN, 
			true
		)

	draw_circle(
		show_range_offset, 
		max_range,
		Color(0.401, 0.865, 0.386, 0.604), 
		false,
		6
	)
	draw_circle(
		show_range_offset, 
		min_range,
		Color(0.401, 0.865, 0.386, 0.604), 
		false,
		6
	)


func _on_offset_data_changed() -> void:
	queue_redraw()	
