@tool
@icon("res://assets/dpi_textures/at-icons/node2d/bullet.svg")
extends Component
class_name BulletComponent
## 子弹组件。
##
## BulletComponent 可以使实体按照飞行轨迹飞行，命中目标后造成影响。


## 飞行轨迹资源。
@export var trajectory: BulletTrajectory = null
## 飞行动画组。
@export var flight_animation: AnimationGroup = null

@export_group("Rotation")
## 子弹旋转速度。
@export var rotation_speed: float = 0.0
## 是否看向目标点，会覆盖 [member rotation_speed]。
@export var look_to: bool = true

@export_group("Hit")
## 是否可以到达目标位置。
@export var can_arrived: bool = true
## 击中目标的阈值。
@export var hit_distance: float = 30.0
## 击中目标后是否移除子弹实体。
@export var hit_remove: bool = true
## 击中后造成伤害的延迟（秒）。
@export var hit_delay: float = 0.0
## 击中动画组。
@export var hit_animation: AnimationGroup = null
## 击中音效组。
@export var hit_sfx: AudioGroup = null
## 击中目标时创建的实体场景路径列表。
@export_file("*.tscn") var hit_payloads := PackedStringArray()

@export_group("Miss")
## 未击中目标时是否移除子弹实体。
@export var miss_remove: bool = true
## 未击中动画组。
@export var miss_animation: AnimationGroup = null
## 未击中音效组。
@export var miss_sfx: AudioGroup = null
## 未击中目标时创建的实体场景路径列表。
@export_file("*.tscn") var miss_payloads := PackedStringArray()

## 影响资源，用于对目标造成伤害或治愈目标。
var influence: Influence = null
## 起始位置。
var from := Vector2.ZERO
## 目标位置。
var to := Vector2.ZERO
## 时间戳（秒）。
var ts: float = 0.0
## 飞行速度（向量）。
var velocity := Vector2.ZERO
## 预判目标位置。
var predict_target_pos := Vector2.ZERO
## 伤害过的实体 ID 列表。
var damaged_entity_ids := PackedInt32Array()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
