extends VBoxContainer
class_name TrackEditor


@warning_ignore_start("unused_signal")
signal item_select(item: TrackEditorTrackItem)
signal item_deselect
signal item_order_changed
@warning_ignore_restore("unused_signal")


@export var track_length: float = 1000
@export var tick_length: float = 10
@export var snap_threshold: float = 4
@export var show_item_order_label: bool = true
@export var order_label_format: String = "%d"

@export_group("Multiple Track")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var multiple_track_enable: bool = false

@export_group("Ref")
@export var track_length_spin_box: SpinBox = null
@export var tick_length_spin_box: SpinBox = null
@export var add_track_button: TextureButton = null
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

var selected_item_list: Array[TrackEditorTrackItem] = []
var tick_size_x: float = 0
var item_list: Array[TrackEditorTrackItem] = []


func _ready() -> void:
	if not multiple_track_enable:
		add_track_button.visible = false
	
	track_length_spin_box.value = track_length
	tick_length_spin_box.value = tick_length
	
	track_length_spin_box.value_changed.connect(_show_ticks)
	tick_length_spin_box.value_changed.connect(_show_ticks)

	_show_ticks()
	
	var first_tick: TrackEditorTick = ruler.get_child(0)
	tick_size_x = first_tick.size.x
	
	create_track()


func select_item(item: TrackEditorTrackItem) -> void:
	selected_item_list.append(item)

	if selected_item_list.size() == 1:
		item_select.emit(item)


func deselect_item() -> void:
	for item: TrackEditorTrackItem in selected_item_list:
		item.is_selected = false
		item.is_draging = false
		
	selected_item_list.clear()
	item_deselect.emit()


func create_item(pos_x: float, track_idx: int = 0) -> void:
	var track: TrackEditorTrack = get_track(track_idx)
	
	var track_item: TrackEditorTrackItem = track_item_scene.instantiate()
	track_item.position = Vector2(pos_x, 2)
	track_item.track_editor = self
	track_item.apply_pos_delta()
	track.item_container.add_child(track_item)

	update_item_list(track_item)
	

func get_item(idx: int, track_idx: int = 0) -> TrackEditorTrackItem:
	var track: TrackEditorTrack = get_track(track_idx)
	return track.item_container.get_child(idx)


func update_item_list(item: TrackEditorTrackItem) -> void:
	var new_item_list: Array[TrackEditorTrackItem] = []

	for track: TrackEditorTrack in track_vbox_container.get_children():
		for child: TrackEditorTrackItem in track.item_container.get_children():
			new_item_list.append(child)

	new_item_list.sort_custom(
		func(a: TrackEditorTrackItem, b: TrackEditorTrackItem) -> bool:
			return a.track_pos < b.track_pos
	)

	item_list = new_item_list
	var in_item_list_idx: int = item_list.find(item)
	if item.idx != in_item_list_idx:
		item.idx = in_item_list_idx
		
		for i: int in item_list.size():
			item_list[i].idx = i
		item_order_changed.emit()


func get_tick_count() -> int:
	return ceili(track_length_spin_box.value / tick_length_spin_box.value)

	
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
		track.queue_free()

		var left_track_tool_bar_item: TrackEditorLeftTrackToolBarItem = left_track_tool_bar.get_child(0)
		left_track_tool_bar_item.queue_free()
		
		var right_track_tool_bar_item: TrackEditorRightTrackToolBarItem = right_track_tool_bar.get_child(0)
		right_track_tool_bar_item.queue_free()


func _show_ticks(_value: float = 0) -> void:
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
