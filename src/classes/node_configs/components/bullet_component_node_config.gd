@tool
extends NodeConfig
class_name BulletComponentNodeConfig
## 子弹组件节点配置资源。


## 飞行轨迹资源。
@export var trajectory: BulletTrajectory = null
## 飞行动画组。
@export var flight_animation: AnimationGroup = null

@export_group("Rotation")
## 子弹旋转速度。
@export var rotation_speed: float = 0.0
## 是否启用看向目标点，会覆盖 [member rotation_speed]。
@export var facing_enabled: bool = true

@export_group("Hit")
## 是否可以到达目标位置。
@export var can_arrived: bool = true
## 击中目标的阈值。
@export var hit_distance: float = 30.0
## 击中目标时的影响资源，用于对目标造成伤害或治愈目标。
@export var hit_influence: Influence = null:
	set(v):
		Utils.rebind_changed(hit_influence, v, emit_changed)
		hit_influence = v
		emit_changed()
## 击中目标后是否移除子弹实体。
@export var hit_remove: bool = true
## 击中后造成伤害的延迟（秒）。
@export var hit_delay: float = 0.0
## 击中动画组。
@export var hit_animation: AnimationGroup = null
## 击中音效组。
@export var hit_sfx: AudioGroup = null
## 击中目标时创建的实体场景路径列表。
@export_file("*.tscn") var hit_payloads: PackedStringArray

@export_group("Miss")
## 未击中目标时是否移除子弹实体。
@export var miss_remove: bool = true
## 未击中动画组。
@export var miss_animation: AnimationGroup = null
## 未击中音效组。
@export var miss_sfx: AudioGroup = null
## 未击中目标时创建的实体场景路径列表。
@export_file("*.tscn") var miss_payloads: PackedStringArray

var _init_connect_property_signals: Dictionary[String, Callable] = {
	"flight_animation": emit_changed,
}


func _init() -> void:
	Utils.connect_property_signals(self, _init_connect_property_signals)