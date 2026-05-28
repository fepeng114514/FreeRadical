extends VBoxContainer
class_name TrackEditorLeftTrackToolBarItem


@export var number_label: Label = null

var track_editor: TrackEditor = null


func _ready() -> void:
	update_number()


func update_number() -> void:
	number_label.text = str(get_index() + 1)
