@tool
extends Entity
class_name TowerEntity


## 塔位场景路径。
@export_file("*.tscn") var tower_holder: String = "":
	set(v): 
		tower_holder = v
		if tower_record:
			tower_record.tower_holder = v
## 默认集结点局部位置。
@export var default_rally_center_position := Vector2.ZERO:
	set(v): 
		default_rally_center_position = v
		if barrack_record:
			barrack_record.default_rally_center_position = v
		update_configuration_warnings()
		
@onready var barrack_record: BarrackRecord = get_node_or_null(Constants.BARRACK_RECORD_NODE_PATH)
@onready var tower_record: TowerRecord = get_node_or_null(Constants.TOWER_RECORD_NODE_PATH)


func _ready() -> void:
	tower_record.tower_holder = tower_holder
	barrack_record.default_rally_center_position = default_rally_center_position


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = super()
		
	if EditorInterface.get_edited_scene_root() != self:
		if not default_rally_center_position:
			warnings.append("请在 default_rally_center_position 中设置一个默认集结点位置。")
		
	return warnings
