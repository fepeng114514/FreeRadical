extends PanelContainer


@export_group("Ref")
## 轨道编辑器引用。
@export var track_editor: TrackEditor = null


func _gui_input(event: InputEvent) -> void:
	track_editor.pointer.position.x = event.position.x
