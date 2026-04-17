@tool
extends Attackbase
class_name MeleeBase
## 近战攻击节点基类
##
## MeleeBase 是 [MelleComponent] 的近战攻击节点的基类，提供了近战攻击的基本属性和功能。


## 冷却时间
@export var cooldown: float = 1
## 击中目标给予的状态效果
@export var mods: Array[String] = []
## 攻击动画数据
@export var animation: AnimationData = null
## 攻击音效数据
@export var sfx: AudioData = null
## 开始攻击到击中目标的延迟，单位为秒
@export var delay: float = 0
## 攻击概率
@export var chance: float = 1
## 是否禁用
@export var disabled: bool = false

@export_group("Damage")
## 最小伤害
@export var damage_min: float = 25
## 最大伤害
@export var damage_max: float = 25
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

## 伤害过的实体 ID 列表
var damaged_entity_ids: Array[int] = []


func _ready() -> void:
	if animation == null:
		animation = AnimationData.new()
		animation.left_right = "melee_left_right"


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"damage_type":
			property.hint_string = "mask_enum:DamageType"
		"damage_flags":
			property.hint_string = "mask_enum:DamageFlag"
