extends Control
class_name TrackEditorTrackItem


@export var order_label: Label = null

## 在轨道上的位置
var track_pos: float = 0
var is_selected: bool = false
var is_draging: bool = false
var last_global_x: float = 0
var last_tick_length: float = -1
var last_idx: int = -1
var idx: int = -1:
	set(v):
		idx = v
		order_label.text = track_editor.order_label_format % (v + 1)

var track_editor: TrackEditor = null


func _ready() -> void:
	track_editor.tick_length_spin_box.value_changed.connect(_on_tick_length_changed)
	last_tick_length = track_editor.tick_length_spin_box.value

	_update_track_pos()


func _on_tick_length_changed(value: float) -> void:
	if last_tick_length:
		position.x = position.x * last_tick_length / value

	_update_track_pos()
	last_tick_length = value


func _gui_input(event: InputEvent) -> void:
	if not is_draging:
		if event.is_action_pressed("ctrl_left_click"):
			select_item()

			if get_index() == 0:
				track_editor.pointer.position.x = position.x
		elif event.is_action_pressed("left_click"):
			track_editor.deselect_item()
			select_item()
			
			track_editor.pointer.position.x = position.x
	else:
		if event.is_action_released("ctrl_left_click") or event.is_action_released("left_click"):
			for item: TrackEditorTrackItem in track_editor.selected_item_list:
				item.is_draging = false
		elif event is InputEventMouseMotion:
			var current_global_x: float = event.global_position.x
			var delta_x: float = current_global_x - last_global_x

			for item: TrackEditorTrackItem in track_editor.selected_item_list:
				item.apply_pos_delta(delta_x)

			track_editor.pointer.position.x = position.x
			last_global_x = global_position.x
			track_editor.update_item_list(self)


func _process(_delta: float) -> void:
	if is_selected:
		modulate = Color.SKY_BLUE
	else:
		modulate = Color.WHITE


func select_item() -> void:
	last_global_x = global_position.x
	is_draging = true
	is_selected = true
	track_editor.select_item(self)


func apply_pos_delta(delta_x: float = 0) -> void:
	var to_pos_x: float = position.x + delta_x

	var tick_length: float = track_editor.tick_size_x
	var t: float = to_pos_x / tick_length
	var f_pos_x: float = ceili(t) * tick_length
	var b_pos_x: float = floori(t) * tick_length

	if abs(f_pos_x - to_pos_x) <= track_editor.snap_threshold:
		to_pos_x = f_pos_x
	elif abs(b_pos_x - to_pos_x) <= track_editor.snap_threshold:
		to_pos_x = b_pos_x
	
	var max_x: float = track_editor.ruler.size.x
	position.x = clampf(to_pos_x, 0, max_x)
	_update_track_pos()


func _update_track_pos() -> void:
	var a: float = track_editor.tick_size_x / track_editor.tick_length_spin_box.value
	track_pos = position.x / a
