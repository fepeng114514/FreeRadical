@tool
@icon("res://assets/dpi_textures/at-icons/node2d/chess_rook.svg")
extends Component
class_name TowerComponent
## 防御塔组件。
##
## [TowerComponent] 可以让实体作为防御塔，可以增加射手实体。


## 防御塔类型枚举。
enum TowerType {
	## 防御塔类型：无。
	NONE,
	## 防御塔类型：箭塔。
	ARCHER,
	## 防御塔类型：兵营。
	BARRACK,
	## 防御塔类型：法师塔。
	MAGE,
	## 防御塔类型：炮塔。
	ARTILLERY,
}


@export var config: TowerComponentNodeConfig = null:
	set(v): 
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()

## 时间戳。
var timestamp: float = 0.0
## 当前轮换到的射手实体索引。
var current_shooter_alternation_index: int = -1


func _ready() -> void:
	super()
	
	process_mode = Node.PROCESS_MODE_INHERIT


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = super()

	for warning in TowerRecord.get_not_found_configuration_warnings(parent):
		warnings.append(warning)

	return warnings
