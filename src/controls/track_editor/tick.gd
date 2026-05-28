extends HBoxContainer
class_name TrackEditorTick


@export_group("Ref")
@export var label: Label = null

var track_editor: TrackEditor = null


func _ready() -> void:
	var tick_length_spin_box: SpinBox = track_editor.tick_length_spin_box
	tick_length_spin_box.value_changed.connect(_update_text)
	
	_update_text(tick_length_spin_box.value)
	
	
func _update_text(value: float) -> void:
	label.text = "%d" % (value * get_index())
