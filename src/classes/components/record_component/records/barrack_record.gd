@tool
extends Record
class_name BarrackRecord
## 兵营记录节点。
##
## [BarrackRecord] 用于存储跨实体的兵营记录信息。


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
## 生成的士兵 ID 列表。
var soldier_ids := PackedInt32Array()


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


func transmit_record(record: BarrackRecord) -> void:
	default_rally_center_position = record.default_rally_center_position
	rally_center_global_position = record.rally_center_global_position
	soldier_ids = record.soldier_ids


static func get_not_found_configuration_warnings(p_parent: Node) -> PackedStringArray:
	var warnings := PackedStringArray()
	
	if p_parent and not p_parent.get_node_or_null(Constants.BARRACK_RECORD_NODE_PATH):
		warnings.append("请为实体增加一个 RecordComponent 节点，并为其增加一个 BarrackRecord 子节点，否则实体无法存储兵营信息。")
	
	return warnings
