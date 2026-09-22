@tool
extends NodeConfig
class_name AuraComponentNodeConfig
## 光环组件节点配置资源。


## 是否跟随目标。
@export var track_target: bool = true
## 相同处理资源。
@export var same_process: SameProcessResource = null
## 是否移除被禁止的光环。
@export var remove_banned: bool = true
## 影响资源，用于对目标造成伤害或治愈目标。
@export var influence: Influence = null:
	set(v):
		influence = v
		emit_changed()
## 搜索资源，用于搜索目标。
@export var searcher: Searcher = null:
	set(v):
		searcher = v
		emit_changed()

@export_group("Cycle")
## 周期时间。
@export var cycle_time: float = 1.0
## 最大周期数。
@export var max_cycle: int = Constants.UNSET
