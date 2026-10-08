@tool
extends Component
class_name ModifierComponent
## 修改器组件。
##
## ModifierComponent 可以使实体持续对其所有者造成影响，例如增加属性值、减少属性值、增加移动速度等。


## 修改器类型枚举。
enum Type {
	## 修改器类型: 无。
	NONE = 0,
	## 修改器类型: 毒。
	POISON = 1,
	## 修改器类型: 火。
	LAVA = 1 << 1,
	## 修改器类型: 流血。
	BLEED = 1 << 2,
	## 修改器类型: 冻结。
	FREEZE = 1 << 3,
	## 修改器类型: 眩晕。
	STUN = 1 << 4,
}


@export var config: ModifierComponentNodeConfig = null:
	set(v): 
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()

## 插入时间戳。
var insert_timestamp: float = 0.0
## 上次影响时间戳。
var influence_timestamp: float = 0.0
## 当前影响次数。
var influence_count: int = 0


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"mod_type":
			property.hint_string = "mask_check(%s)" % Type


func _draw() -> void:
	if not config:
		return
		
	if DebugManager.draw_range_enabled:
		if config.influence:
			config.influence.draw_influence_range(self, position)
