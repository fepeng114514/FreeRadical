@tool
extends Record
class_name TowerRecord
## 防御塔记录组件。
##
## TowerRecord 用于存储跨实体的防御塔信息。


# 需要支持外部修改
## 塔位场景路径。
@export_file("*.tscn") var tower_holder: String = ""
## 默认集结点局部位置。
@export var default_rally_center_position := Vector2.ZERO:
	set(v):
		default_rally_center_position = v
		queue_redraw()

## 集结点全局位置。
var rally_center_global_position := Vector2.ZERO:
	set(v):
		rally_center_global_position = v
		queue_redraw()
## 上一次生成的士兵列表。
var last_soldier_list: Array[Entity] = []


func _ready() -> void:
	if Engine.is_editor_hint():
		return
		
	if not tower_holder:
		tower_holder = GameManager.default_tower_holder


func _draw() -> void:
	if DebugManager.draw_point_enabled:
		if default_rally_center_position:
			draw_circle(
				default_rally_center_position,
				9,
				Color.BLUE,
				true
			)
			draw_dashed_line(
				default_rally_center_position,
				position,
				Color.BLUE,
				2
			)


func transmit_record(record: TowerRecord) -> void:
	tower_holder = record.tower_holder
	default_rally_center_position = record.default_rally_center_position
	rally_center_global_position = record.rally_center_global_position
	last_soldier_list = record.last_soldier_list


static func get_not_found_configuration_warnings(p_parent: Node) -> PackedStringArray:
	var warnings := PackedStringArray()
	
	if p_parent and not p_parent.get_node_or_null(Constants.TOWER_RECORD_NODE_PATH):
		warnings.append("请为实体增加一个 RecordComponent 节点，并为其增加一个 TowerRecord 子节点，否则实体无法存储防御塔信息。")
	
	return warnings
