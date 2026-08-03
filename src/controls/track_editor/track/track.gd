extends PanelContainer
class_name TrackEditorTrack


@export_group("Ref")
## 项容器引用。
@export var item_container: Control = null

## 轨道编辑器引用。
var track_editor: TrackEditor = null


func _gui_input(event: InputEvent) -> void:
	if track_editor.mouse_tool_bar.opened_tools & TrackEditorMouseToolButton.ToolFlag.EDIT:
		if event.is_action_pressed("track_editor_click"):
			_create_item(event)
	else:
		if event.is_action_pressed("track_editor_click"):
			track_editor.deselect_item()

		if event.is_action_pressed("track_editor_create_key"):
			_create_item(event)


## 创建项。
func _create_item(event: InputEvent) -> void:
	var track_item: TrackEditorTrackItem = track_editor.create_item(get_index())
	track_item.position.x = event.position.x
	track_item.apply_pos_delta(0)
	track_editor.insert_item(track_item)
