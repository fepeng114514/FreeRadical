@tool
extends NodeConfig
class_name AuraComponentNodeConfig
## 光环组件节点配置资源。


## 等级。
@export var level: int = 0
## 是否跟随目标。
@export var track_target: bool = true
## 相同光环叠加策略资源。
@export var same_stack_policy: SameAuraStackPolicy = null
## 是否移除被禁止的光环。
@export var remove_banned: bool = true
## 搜索资源，用于搜索目标。
@export var searcher: Searcher = null:
	set(v):
		Utils.rebind_changed(searcher, v, emit_changed)
		searcher = v
		emit_changed()

@export_group("Influence")
## 影响资源，用于对目标造成伤害或治愈目标。
@export var influence: Influence = null:
	set(v):
		Utils.rebind_changed(influence, v, emit_changed)
		influence = v
		emit_changed()
## 造成影响间隔时间。
@export var influence_interval: float = 1.0
## 最大影响次数，-1 表示无限次数。
@export var max_influence_count: int = Constants.UNSET
## 影响延迟时间。
@export var influence_delay: float = 0.0
## 影响动画。
@export var influence_animation: AnimationGroup = null

var _init_connect_property_signals: Dictionary[String, Callable] = {
	"searcher": emit_changed,
	"influence": emit_changed,
}


func _init() -> void:
	Utils.connect_property_signals(self, _init_connect_property_signals)