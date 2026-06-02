extends PanelContainer
class_name TrackEditorTrack


@export_group("Ref")
@export var item_container: Control = null

var track_editor: TrackEditor = null


func _gui_input(event: InputEvent) -> void:
	track_editor.pointer.position.x = event.position.x

	if track_editor.mouse_tool_bar.opened_tools & TrackEditorMouseToolButton.ToolFlag.EDIT:
		if event.is_action_pressed("track_editor_click"):
			track_editor.create_item(event.position.x, get_index())
	else:
		if event.is_action_pressed("track_editor_click"):
			track_editor.deselect_item()

		if event.is_action_pressed("track_editor_create_key"):
			track_editor.create_item(event.position.x, get_index())
