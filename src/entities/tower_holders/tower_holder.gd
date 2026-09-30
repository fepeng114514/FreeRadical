@tool
extends Entity
class_name TowerHolderEntity


## 默认集结点局部位置。
@export var default_rally_center_position := Vector2.ZERO:
	set(v): 
		default_rally_center_position = v
		if tower_record:
			tower_record.default_rally_center_position = v
		update_configuration_warnings()
		
@onready var tower_record: TowerRecord = get_node_or_null(Constants.CN_TOWER_RECORD)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = super()
		
	if not default_rally_center_position:
		warnings.append("请在 default_rally_center_position 中设置一个默认集结点位置。")
		
	return warnings
