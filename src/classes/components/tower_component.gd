@tool
@icon("res://assets/dpi_textures/at-icons/node2d/chess_rook.svg")
extends Component
class_name TowerComponent
## 防御塔组件。
##
## TowerComponent 可以使实体拥有防御塔的能力，可被出售与升级，同时也可以管理射手实体，射手以子节点的形式存在。


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

## 防御塔类型。
@export var tower_type: TowerType = TowerType.NONE

@export_group("Shooter Switch")
## 是否启用射手轮换释放技能。
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var shooter_alternation_enabled: bool = false
## 轮换的射手实体索引列表。
@export var shooter_alternation_indexes: Array[int] = []
## 轮换释放技能偏移时间（秒）。
@export var shooter_alternation_offset: float = 0.1

## 塔位。
var tower_holder: String = ""
## 时间戳。
var time_stamp: float = 0.0
## 当前轮换到的射手实体索引。
var shooter_alternation_index: int = -1


func _ready() -> void:
	super()
	
	process_mode = Node.PROCESS_MODE_INHERIT


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = super()

	for warning in TowerRecord.get_not_found_configuration_warnings(parent):
		warnings.append(warning)

	return warnings
