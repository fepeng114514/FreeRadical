@tool
@icon("res://assets/dpi_textures/at-icons/node2d/chess_rook.svg")
extends Component
class_name TowerComponent
## 防御塔组件。
##
## TowerComponent 可以使实体拥有防御塔的能力，可被出售与升级，同时也可以管理射手实体，射手以子节点的形式存在。


## 防御塔类型枚举。
enum TowerType {
	## 防御塔类型：塔位。
	TOWER_HOLDER,
	## 防御塔类型：箭塔。
	TOWER_ARCHER,
	## 防御塔类型：兵营。
	TOWER_BARRACK,
	## 防御塔类型：法师塔。
	TOWER_MAGE,
	## 防御塔类型：炮塔。
	TOWER_ARTILLERY,
	## 防御塔类型：建造。
	TOWER_BUILD,
}


## 防御塔类型。
@export var tower_type: TowerType = TowerType.TOWER_HOLDER
## 塔位场景路径。
@export_file("*.tscn") var tower_holder: String = ""
## 默认集结点。
@export var default_rally_center_local_pos := Vector2.ZERO:
	set(v): 
		default_rally_center_local_pos = v
		U.redraw_setter(self)

@export_group("Sell")
## 价格。
@export var price: float = 0.0
## 出售比例（%）
@export var sell_ratio: float = 0.5
## 出售音效组。
@export var sell_sfx: AudioGroup = null

@export_group("Shooter Switch")
## 是否启用射手轮换释放技能。
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var shooter_switch_enable: bool = false
## 轮换的射手实体列表。
@export var shooter_switch_list: Array[Entity] = []
## 轮换释放技能偏移时间（秒）。
@export var shooter_switch_offset: float = 0.1

## 总价格。
var total_price: float = price
## 升级目标场景路径。
var upgrade_to: String = ""
## 出售状态。
var is_sell: bool = false
## 是否是被建筑建造的防御塔。
var is_builded: bool = false
## 时间戳。
var ts: float = 0.0
## 当前轮换到的射手实体索引。
var current_shooter_switch_idx: int = -1


func _draw() -> void:
	if Engine.is_editor_hint():
		if default_rally_center_local_pos:
			draw_circle(
				default_rally_center_local_pos,
				9,
				Color.BLUE, 
				true
			)
			draw_line(
				default_rally_center_local_pos, 
				position, 
				Color.BLUE, 
				2
			)
		
