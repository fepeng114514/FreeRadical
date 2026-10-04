@tool
extends SkillNodeConfig
class_name MeleeSkillNodeConfig
## 近战技能节点配置资源。


## 影响资源，用于对目标造成伤害或治愈目标。
@export var influence: Influence = null:
	set(v):
		Utils.rebind_changed(influence, v, emit_changed)
		influence = v
		emit_changed()
## 是否启用搜索第一个目标位置，如果为 false 则以释放者的位置为中心造成影响，而非第一个目标的位置。
@export var search_at_target_position_enabled: bool = false
## 交互策略。
@export var interact_policy: InteractPolicy = null:
	set(v):
		Utils.rebind_changed(interact_policy, v, emit_changed)
		interact_policy = v
		emit_changed()

var _init_connect_property_signals: Dictionary[String, Callable] = {
	"influence": emit_changed,
	"interact_policy": emit_changed,
}


func _init() -> void:
	Utils.connect_property_signals(self, _init_connect_property_signals)