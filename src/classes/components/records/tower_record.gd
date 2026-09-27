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


static func get_not_found_configuration_warnings(p_parent: Node) -> PackedStringArray:
	var warnings := PackedStringArray()
	
	if p_parent and not p_parent.get_node_or_null("TowerRecord"):
		warnings.append("请增加一个 TowerRecord 子节点，否则实体无法存储防御塔信息。")
	
	return warnings
