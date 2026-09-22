@tool
extends NodeConfig
class_name MeleeComponentNodeConfig
## 近战组件节点配置资源。


## 是否不主动前往近战位置。
@export var is_passive: bool = false
## 移动速度。
@export var speed: float = 100.0
## 移动动画组。
@export var motion_animation: AnimationGroup = null
## 近战位置偏移组。
@export var melee_position_offsets: OffsetGroup = null:
	set(v):
		melee_position_offsets = v
		emit_changed()
## 到达位置的阈值。
@export var arrived_distance: float = 10.0

@export_group("Blocker")
## 搜索资源，用于搜索目标。
@export var searcher: Searcher = null:
	set(v):
		searcher = v
		emit_changed()
## 最大可以拦截数量。
@export var max_blocked_count: int = 1

@export_group("Blocked")
## 拦截成本。
@export var block_cost: int = 1
