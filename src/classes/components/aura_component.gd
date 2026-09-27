@tool
extends Component
class_name AuraComponent
## 光环组件。
##
## AuraComponent 可以使实体可周期性对范围内其他实体造成影响。


## 光环类型枚举。
enum Type {
	## 光环类型: 无。
	NONE = 0,
	## 光环类型: 正面效果。
	BUFF = 1,
	## 光环类型: 负面效果。
	DEBUFF = 1 << 1,
}


@export var config: AuraComponentNodeConfig = null:
	set(v): 
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()

## 是否跟随目标。
@export var track_target: bool = true
## 相同处理资源。
@export var same_process: SameProcessResource = null
## 是否移除被禁止的光环。
@export var remove_banned: bool = true
## 影响资源，用于对目标造成伤害或治愈目标。
@export var influence: Influence = null
## 搜索资源，用于搜索目标。
@export var searcher: Searcher = null

@export_group("Cycle")
## 周期时间。
@export var cycle_time: float = 1.0
## 最大周期数。
@export var max_cycle: int = Constants.UNSET

## 当前周期数。
var current_cycle: int = 0
## 时间戳。
var time_stamp: float = 0.0


func _validate_property(property: Dictionary):
	match property.name:
		"aura_type":
			property.hint_string = "mask_check(%s)" % Type


func _draw() -> void:
	if DebugManager.draw_range_enabled:
		if searcher:
			searcher.draw_search_range(self, position)
		if influence:
			influence.draw_influence_range(self, position)