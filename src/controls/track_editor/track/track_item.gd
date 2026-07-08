extends Control
class_name TrackEditorTrackItem


## 位于轨道上的位置标签。
@export var track_pos_x_label: Label = null
## 项顺序标签。
@export var order_label: Label = null

## 位于轨道上的 X 位置。
var track_pos_x: float = 0.0:
	set(v):
		track_pos_x = v
		track_pos_x_label.text = "%.2f" % v
## 是否选中。
var is_selected: bool = false
## 是否拖动中。
var is_draging: bool = false
## 上一次拖动时的全局位置。
var last_global_x: float = 0.0
## 上一次刻度间距。
var last_tick_spacing: float = -1
## 所属轨道索引。
var track_idx: int = -1
## 项索引。
var idx: int = -1:
	set(v):
		idx = v
		order_label.text = track_editor.order_label_format % (v + 1)
## 上一次的项索引。
var last_idx: int = -1

## 所属轨道编辑器。
var track_editor: TrackEditor = null


func _ready() -> void:
	track_editor.tick_spacing_spin_box.value_changed.connect(_on_tick_spacing_changed)
	last_tick_spacing = track_editor.tick_spacing_spin_box.value

	_update_track_pos_x()


func _on_tick_spacing_changed(value: float) -> void:
	if last_tick_spacing:
		position.x = position.x * last_tick_spacing / value

	_update_track_pos_x()
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
					move(event.global_position)
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
					move(event.global_position)


func _process(_delta: float) -> void:
	if is_selected:
		modulate = Color.SKY_BLUE
	else:
		modulate = Color.WHITE


## 选中项。
func select() -> void:
	track_editor.deselect_item()
	last_global_x = global_position.x
	is_draging = true
	track_editor.select_item(self)
	
	track_editor.pointer.position.x = position.x


## 擦除项。
func erase() -> void:
	track_editor.erase_item(self)


## 移动项。
func move(global_pos: Vector2) -> void:
	var current_global_x: float = global_pos.x
	var delta_x: float = current_global_x - last_global_x

	apply_pos_delta(delta_x)
	
	track_editor.pointer.position.x = position.x
	last_global_x = global_position.x
	track_editor.update_item_list()
	track_editor.item_moved.emit(self)
	track_editor.update_item_list_last_idx()


## 应用位置增量。
func apply_pos_delta(delta_x: float = 0.0) -> void:
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
	_update_track_pos_x()


## 通过轨道位置设置项位置。
func set_track_pos_x(new_track_pos_x: float) -> void:
	var l: float = track_editor.tick_size_x / track_editor.tick_spacing_spin_box.value
	position.x = new_track_pos_x * l
	track_pos_x = new_track_pos_x


func get_relative_track_pos_x() -> float:
	var last_item_track_pos_x: float = track_editor.item_list[idx - 1].track_pos_x if idx > 0 else 0.0
	var relative_track_pos_x: float = track_pos_x - last_item_track_pos_x
	return relative_track_pos_x


## 更新项位置。
func _update_track_pos_x() -> void:
	var l: float = track_editor.tick_size_x / track_editor.tick_spacing_spin_box.value
	track_pos_x = position.x / l
