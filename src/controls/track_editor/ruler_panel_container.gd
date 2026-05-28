extends PanelContainer


@export_group("Ref")
@export var track_editor: TrackEditor = null


func _gui_input(event: InputEvent) -> void:
	track_editor.pointer.position.x = event.position.x
