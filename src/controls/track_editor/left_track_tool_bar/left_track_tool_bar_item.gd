extends VBoxContainer
class_name TrackEditorLeftTrackToolBarItem


## 轨道序号标签引用。
@export var track_order_label: Label = null

## 轨道编辑器引用。
var track_editor: TrackEditor = null


func _ready() -> void:
	update_track_order_label()


## 更新轨道序号标签。
func update_track_order_label() -> void:
	track_order_label.text = str(get_index() + 1)
