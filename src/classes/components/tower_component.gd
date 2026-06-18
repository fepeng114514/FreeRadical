@tool
extends Component
class_name TowerComponent
## 防御塔组件。
##
## TowerComponent 可以使实体拥有防御塔的能力，可被出售与升级。


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
## 显示范围的偏移。
@export var show_range_offset := Vector2.ZERO:
	set(v): 
		show_range_offset = v
		U.redraw_setter(self)
## 塔位样式。
@export var tower_holder: PackedScene = null
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

## 总价格。
var total_price: float = price
## 升级目标。
var upgrade_to: PackedScene = null
## 出售状态。
var is_sell: bool = false
## 是否是被建筑建造的防御塔。
var is_builded: bool = false
## 时间戳。
var ts: float = 0.0

## 持有此组件的实体。
@onready var entity: Entity = get_parent()


func _draw() -> void:
	if Engine.is_editor_hint():
		draw_circle(
			show_range_offset, 
			3,
			Color.GREEN, 
			true
		)
		
		if default_rally_center_local_pos != Vector2.ZERO:
			draw_circle(
				default_rally_center_local_pos,
				9,
				Color.BLUE, 
				true
			)
			draw_line(
				default_rally_center_local_pos, 
				to_local(entity.global_position), 
				Color.BLUE, 
				2
			)
