extends HBoxContainer
class_name TrackEditorTick


@export_group("Ref")
## 标签引用。
@export var label: Label = null

## 轨道编辑器引用。
var track_editor: TrackEditor = null


func _ready() -> void:
	var tick_spacing_spin_box: SpinBox = track_editor.tick_spacing_spin_box
	tick_spacing_spin_box.value_changed.connect(_update_text)
	
	_update_text(tick_spacing_spin_box.value)
	

## 更新标签文本。
func _update_text(value: float) -> void:
	label.text = "%d" % (value * get_index())
