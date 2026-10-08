@tool
extends Record
class_name TowerRecord
## 防御塔记录组件。
##
## TowerRecord 用于存储跨实体的防御塔信息。


# 需要支持外部修改
## 塔位场景路径。
@export_file("*.tscn") var tower_holder: String = ""


func _ready() -> void:
	if Engine.is_editor_hint():
		return
		
	if not tower_holder:
		tower_holder = GameManager.default_tower_holder


func transmit_record(record: TowerRecord) -> void:
	tower_holder = record.tower_holder


static func get_not_found_configuration_warnings(p_parent: Node) -> PackedStringArray:
	var warnings := PackedStringArray()
	
	if p_parent and not p_parent.get_node_or_null(Constants.TOWER_RECORD_NODE_PATH):
		warnings.append("请为实体增加一个 RecordComponent 节点，并为其增加一个 TowerRecord 子节点，否则实体无法存储防御塔信息。")
	
	return warnings
