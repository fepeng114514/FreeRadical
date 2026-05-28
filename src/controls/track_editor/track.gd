extends PanelContainer
class_name TrackEditorTrack


@export_group("Ref")
@export var item_container: Control = null

var track_editor: TrackEditor = null


func _gui_input(event: InputEvent) -> void:
	track_editor.pointer.position.x = event.position.x

	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if event.pressed:
					track_editor.deselect_item()
			MOUSE_BUTTON_RIGHT:
				if event.pressed:
					track_editor.create_item(event.position.x, get_index())
