extends PanelContainer
class_name TrackEditor


@warning_ignore_start("unused_signal")
signal item_select(item: TrackEditorTrackItem)
signal item_deselect
signal item_create(item: TrackEditorTrackItem)
signal item_erase(item: TrackEditorTrackItem)
signal item_order_changed
@warning_ignore_restore("unused_signal")


@export var track_length: float = 1000:
	set(v): 
		track_length = v
		if track_length_spin_box:
			track_length_spin_box.value = v
@export var tick_spacing: float = 10:
	set(v): 
		tick_spacing = v
		if tick_spacing_spin_box:
			tick_spacing_spin_box.value = v
@export var snap_threshold: float = 4
@export var show_item_order_label: bool = true
@export var order_label_format: String = "%d"
@export var hide_mouse_tool_bar: bool = false

@export_group("Multiple Track")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var multiple_track_enable: bool = false

@export_group("Ref")
@export var track_length_spin_box: SpinBox = null
@export var tick_spacing_spin_box: SpinBox = null
@export var mouse_tool_bar: TrackEditorMouseToolBar = null
@export var add_track_button: Button = null
@export var ruler: HBoxContainer = null
@export var pointer: Control = null
@export var track_vbox_container: VBoxContainer = null
@export var left_track_tool_bar: VBoxContainer = null
@export var right_track_tool_bar: VBoxContainer = null

@export var tick_scene: PackedScene = null
@export var track_item_scene: PackedScene = null
@export var track_scene: PackedScene = null
@export var left_track_tool_bar_item_scene: PackedScene = null
@export var right_track_tool_bar_item_scene: PackedScene = null

var selected_item: TrackEditorTrackItem = null
var item_list: Array[TrackEditorTrackItem] = []
var tick_size_x: float = 0.0


func _ready() -> void:
	track_length_spin_box.value = track_length
	tick_spacing_spin_box.value = tick_spacing
	
	if hide_mouse_tool_bar:
		mouse_tool_bar.visible = false

	if not multiple_track_enable:
		add_track_button.visible = false
	
	track_length_spin_box.value_changed.connect(_show_ticks)
	tick_spacing_spin_box.value_changed.connect(_show_ticks)

	_show_ticks()
	
	var first_tick: TrackEditorTick = ruler.get_child(0)
	tick_size_x = first_tick.size.x
	
	create_track()


func select_item(item: TrackEditorTrackItem) -> void:
	selected_item = item
	item.is_selected = true
	item_select.emit(item)


func deselect_item() -> void:
	if not selected_item:
		return
		
	selected_item.is_selected = false
	selected_item.is_draging = false
		
	selected_item = null
	item_deselect.emit()


func create_item(track_idx: int = 0) -> TrackEditorTrackItem:
	var track: TrackEditorTrack = get_track(track_idx)
	
	var track_item: TrackEditorTrackItem = track_item_scene.instantiate()
	track_item.position.y = 2
	track_item.track_editor = self
	track_item.track_idx = track_idx
	track.item_container.add_child(track_item)

	item_create.emit(track_item)
	return track_item


func erase_item(item: TrackEditorTrackItem) -> void:
	item.queue_free()
	item.removed = true
	update_item_list()
	item_erase.emit(item)
		
	
func get_item(idx: int, track_idx: int = 0) -> TrackEditorTrackItem:
	var track: TrackEditorTrack = get_track(track_idx)
	return track.item_container.get_child(idx)


func update_item_list() -> void:
	var new_item_list: Array[TrackEditorTrackItem] = []

	for track: TrackEditorTrack in track_vbox_container.get_children():
		for child: TrackEditorTrackItem in track.item_container.get_children():
			if child.removed:
				continue

			new_item_list.append(child)

	new_item_list.sort_custom(
		func(a: TrackEditorTrackItem, b: TrackEditorTrackItem) -> bool:
			var a_track_pos: float = a.track_pos
			var b_track_pos: float = b.track_pos

			if a_track_pos == b_track_pos:
				return a.track_idx < b.track_idx
			else:
				return a_track_pos < b_track_pos
	)

	item_list = new_item_list
	var item_list_size: int = item_list.size()

	for i: int in item_list_size:
		var item_v: TrackEditorTrackItem = item_list[i]
		item_v.idx = i

	var has_order_changed: bool = false

	for i: int in item_list_size:
		var item_v: TrackEditorTrackItem = item_list[i]
		if item_v.last_idx != item_v.idx:
			if not has_order_changed:
				has_order_changed = true
				item_order_changed.emit()
			item_v.last_idx = item_v.idx


func get_tick_count() -> int:
	return ceili(track_length_spin_box.value / tick_spacing_spin_box.value)

	
func get_track(track_idx: int = 0) -> TrackEditorTrack:
	return track_vbox_container.get_child(track_idx)
	

func create_track() -> void:
	var track: TrackEditorTrack = track_scene.instantiate()
	track.track_editor = self
	track_vbox_container.add_child(track)
	
	if multiple_track_enable:
		var left_track_tool_bar_item: TrackEditorLeftTrackToolBarItem = left_track_tool_bar_item_scene.instantiate()
		left_track_tool_bar_item.track_editor = self
		left_track_tool_bar.add_child(left_track_tool_bar_item)
		
		var right_track_tool_bar_item: TrackEditorRightTrackToolBarItem = right_track_tool_bar_item_scene.instantiate()
		right_track_tool_bar_item.track_editor = self
		right_track_tool_bar.add_child(right_track_tool_bar_item)
			

func clear_tracks() -> void:
	for track: TrackEditorTrack in track_vbox_container.get_children():
		track.free()

		if left_track_tool_bar.get_child_count() > 0:
			var left_track_tool_bar_item: TrackEditorLeftTrackToolBarItem = left_track_tool_bar.get_child(0)
			left_track_tool_bar_item.free()
			
		if right_track_tool_bar.get_child_count() > 0:
			var right_track_tool_bar_item: TrackEditorRightTrackToolBarItem = right_track_tool_bar.get_child(0)
			right_track_tool_bar_item.free()
		

func _show_ticks(_value: float = 0.0) -> void:
	var target_tick_count: int = get_tick_count()
	var has_tick_count: int = ruler.get_child_count()

	# 创建刻度节点
	if has_tick_count < target_tick_count:
		for i: int in range(has_tick_count, target_tick_count):
			var tick: TrackEditorTick = tick_scene.instantiate()
			tick.track_editor = self
			ruler.add_child(tick)
	elif has_tick_count > target_tick_count:
		for i: int in range(target_tick_count, has_tick_count):
			var tick: TrackEditorTick = ruler.get_child(i)
			tick.visible = false

	for i: int in target_tick_count:
		var tick: TrackEditorTick = ruler.get_child(i)
		tick.visible = true
