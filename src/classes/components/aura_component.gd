@tool
extends Component
class_name AuraComponent
## 光环组件。
##
## [AuraComponent] 可以让实体周期性对范围内其他实体造成影响。


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
		queue_redraw()

## 目标实体 ID。
var target_id: int = Constants.UNSET
## 插入时间戳。
var insert_timestamp: float = 0.0
## 当前影响次数。
var current_influence_count: int = 0
## 影响间隔时间戳。
var influence_timestamp: float = 0.0


func _validate_property(property: Dictionary):
	match property.name:
		"aura_type":
			property.hint_string = "mask_check(%s)" % Type


func _draw() -> void:
	if not config:
		return
		
	if DebugManager.draw_range_enabled:
		if config.searcher:
			config.searcher.draw_search_range(self, position)
		if config.influence:
			config.influence.draw_influence_range(self, position)