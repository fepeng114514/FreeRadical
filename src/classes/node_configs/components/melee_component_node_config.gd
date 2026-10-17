@tool
extends NodeConfig
class_name MeleeComponentNodeConfig
## 近战组件节点配置资源。
##
## [MeleeComponentNodeConfig] 用于存储 [MeleeComponent] 的可配置数据。


## 是否不主动前往近战位置。
@export var is_passive: bool = false
## 移动速度。
@export var speed: float = 100.0
## 移动动画组。
@export var motion_animation: FacingAnimationSet = null
## 近战位置偏移组。
@export var melee_position_offsets: OffsetGroup = null:
	set(v):
		Utils.rebind_changed(melee_position_offsets, v, emit_changed)
		melee_position_offsets = v
		emit_changed()
## 到达位置的阈值。
@export var arrived_distance: float = 10.0

@export_group("Blocker")
## 搜索资源，用于搜索目标。
@export var searcher: Searcher = null:
	set(v):
		Utils.rebind_changed(searcher, v, emit_changed)
		searcher = v
		emit_changed()
## 最大可以拦截数量。
@export var max_blocked_count: int = 1

@export_group("Blocked")
## 拦截成本。
@export var block_cost: int = 1

var _init_connect_property_signals: Dictionary[String, Callable] = {
	"melee_position_offsets": emit_changed,
	"searcher": emit_changed,
}


func _init() -> void:
	super()
		
	Utils.connect_property_signals(self, _init_connect_property_signals)