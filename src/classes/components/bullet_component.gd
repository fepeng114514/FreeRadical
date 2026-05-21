@tool
extends Node2D
class_name BulletComponent
## 子弹组件
##
## BulletComponent 可以使实体按照飞行轨迹飞行，命中目标后造成影响


## 飞行轨迹资源
@export var trajectory: BulletTrajectory = null
## 飞行动画数据
@export var flight_animation: AnimationGroup = null

@export_group("Rotation")
## 子弹旋转速度（弧度）
@export var rotation_speed: float = 0
## 是否看向目标点，会覆盖 rotation_speed
@export var look_to: bool = true

@export_group("Hit")
## 是否可以到达目标位置
@export var can_arrived: bool = true
## 击中目标的阈值
@export var hit_distance: float = 20
## 击中目标后是否移除子弹实体
@export var hit_remove: bool = true
## 击中后造成伤害的延迟（秒）
@export var hit_delay: float = 0
## 击中动画
@export var hit_animation: AnimationGroup = null
## 击中音效
@export var hit_sfx: AudioGroup = null
## 击中目标时创建的实体场景名称
@export var hit_payloads := PackedStringArray()

@export_group("Miss")
## 未击中目标时是否移除子弹实体
@export var miss_remove: bool = true
## 未击中动画数据
@export var miss_animation: AnimationGroup = null
## 未击中音效数据
@export var miss_sfx: AudioGroup = null
## 未击中目标时创建的实体场景名称
@export var miss_payloads := PackedStringArray()

## 伤害/治疗/范围伤害 统一资源（由 SkillRanged 在生成子弹时传入）
var influence: InfluenceResource = null
## 起始位置
var from := Vector2.ZERO
## 目标位置
var to := Vector2.ZERO
## 时间戳（秒）
var ts: float = 0
## 子弹向量速度
var velocity := Vector2.ZERO
## 预判目标位置
var predict_target_pos := Vector2.ZERO
## 伤害过的实体 ID 列表
var damaged_entity_ids := PackedInt32Array()
