extends Control
class_name TrackEditorTrackItem


@export var order_label: Label = null

var removed: bool = false
## 在轨道上的位置
var track_pos: float = 0
var is_selected: bool = false
var is_draging: bool = false
var last_global_x: float = 0
var last_tick_spacing: float = -1
var last_idx: int = -1
var idx: int = -1:
	set(v):
		idx = v
		order_label.text = track_editor.order_label_format % (v + 1)

var track_editor: TrackEditor = null


func _ready() -> void:
	track_editor.tick_spacing_spin_box.value_changed.connect(_on_tick_spacing_changed)
	last_tick_spacing = track_editor.tick_spacing_spin_box.value

	_update_track_pos()


func _on_tick_spacing_changed(value: float) -> void:
	if last_tick_spacing:
		position.x = position.x * last_tick_spacing / value

	_update_track_pos()
	last_tick_spacing = value


func _gui_input(event: InputEvent) -> void:
	if track_editor.mouse_tool_bar.opened_tools & TrackEditorMouseToolButton.ToolFlag.SELECT:
		if not is_draging:
			if event.is_action_pressed("track_editor_select_key"):
				select()
			elif event.is_action_pressed("track_editor_erase_key"):
				erase()
		else:
			if event.is_action_released("track_editor_select_key"):
				is_draging = false
			else:
				if event is InputEventMouseMotion:
					drag_move(event)
	elif track_editor.mouse_tool_bar.opened_tools & TrackEditorMouseToolButton.ToolFlag.ERASE:
		if event.is_action_pressed("track_editor_click"):
			erase()
	elif track_editor.mouse_tool_bar.opened_tools & TrackEditorMouseToolButton.ToolFlag.MOVE:
		if not is_draging:
			if event.is_action_pressed("track_editor_select_key"):
				is_draging = true
		else:
			if event.is_action_released("track_editor_select_key"):
				is_draging = false
			else:
				if event is InputEventMouseMotion:
					drag_move(event)


func _process(_delta: float) -> void:
	if is_selected:
		modulate = Color.SKY_BLUE
	else:
		modulate = Color.WHITE


func select() -> void:
	track_editor.deselect_item()
	last_global_x = global_position.x
	is_draging = true
	track_editor.select_item(self)
	
	track_editor.pointer.position.x = position.x


func erase() -> void:
	track_editor.erase_item(self)


func drag_move(event: InputEventMouseMotion) -> void:
	var current_global_x: float = event.global_position.x
	var delta_x: float = current_global_x - last_global_x

	apply_pos_delta(delta_x)

	track_editor.pointer.position.x = position.x
	last_global_x = global_position.x
	track_editor.update_item_list()


func apply_pos_delta(delta_x: float = 0) -> void:
	var to_pos_x: float = position.x + delta_x

	if track_editor.mouse_tool_bar.opened_tools & TrackEditorMouseToolButton.ToolFlag.SNAP:
		var tick_spacing: float = track_editor.tick_size_x
		var t: float = to_pos_x / tick_spacing
		var f_pos_x: float = ceili(t) * tick_spacing
		var b_pos_x: float = floori(t) * tick_spacing
		var snap_threshold: float = track_editor.snap_threshold

		if abs(f_pos_x - to_pos_x) <= snap_threshold:
			to_pos_x = f_pos_x
		elif abs(b_pos_x - to_pos_x) <= snap_threshold:
			to_pos_x = b_pos_x
	
	var max_x: float = track_editor.ruler.size.x
	position.x = clampf(to_pos_x, 0, max_x)
	_update_track_pos()


func _update_track_pos() -> void:
	var a: float = track_editor.tick_size_x / track_editor.tick_spacing_spin_box.value
	track_pos = position.x / a
