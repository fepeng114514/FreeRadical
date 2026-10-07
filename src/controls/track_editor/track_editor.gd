@tool
extends PanelContainer
class_name TrackEditor
## 轨道编辑器。
##
## TrackEditor 适用于时间轴可视化编辑等场景。


@warning_ignore_start("unused_signal")
## 轨道项选中时发出。
signal item_selected(item: TrackEditorTrackItem)
## 轨道项取消选中时发出。
signal item_deselected(item: TrackEditorTrackItem)
## 轨道项插入时发出。
signal item_inserted(item: TrackEditorTrackItem)
## 轨道项删除时发出。
signal item_deleted(item: TrackEditorTrackItem)
## 轨道项移动时发出。
signal item_moved(item: TrackEditorTrackItem)
@warning_ignore_restore("unused_signal")


## 轨道长度。
@export var track_length: float = 1000:
	set(v): 
		track_length = v
		if track_length_spin_box:
			track_length_spin_box.value = v
## 轨道刻度长度。
@export var tick_length: float = 10:
	set(v): 
		tick_length = v
		if tick_length_spin_box:
			tick_length_spin_box.value = v
## 项拖动时的吸附阈值。
@export var snap_threshold: float = 4.0
## 是否显示项顺序标签。
@export var show_item_order_label: bool = true
## 项顺序标签格式。
@export var order_label_format: String = "%d"
## 是否隐藏鼠标工具栏。
@export var hide_mouse_tool_bar: bool = false:
	set(v):
		hide_mouse_tool_bar = v
		if mouse_tool_bar:
			if v:
				_hide_mouse_tool_bar()
			else:
				_show_mouse_tool_bar()

@export_group("Multiple Track")
## 是否启用多轨道模式。
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var multiple_track_enable: bool = true:
	set(v):
		multiple_track_enable = v
		if add_track_button:
			if v:
				_hide_multiple_track_section()
			else:
				_show_multiple_track_section()

@export_group("Ref")
## 轨道长度旋钮引用。
@export var track_length_spin_box: SpinBox = null
## 轨道刻度长度数值调节框引用。
@export var tick_length_spin_box: SpinBox = null
## 鼠标工具栏引用。
@export var mouse_tool_bar: TrackEditorMouseToolBar = null
## 添加轨道按钮引用。
@export var add_track_button: Button = null
## 轨道刻度容器引用。
@export var ruler: HBoxContainer = null
## 轨道指针引用。
@export var pointer: Control = null
## 轨道容器引用。
@export var track_vbox_container: VBoxContainer = null
## 左轨道工具栏引用。
@export var left_track_tool_bar: VBoxContainer = null
## 右轨道工具栏引用。
@export var right_track_tool_bar: VBoxContainer = null

@export_subgroup("Scenes")
## 轨道刻度场景引用。
@export var tick_scene: PackedScene = null
## 轨道项场景引用。
@export var track_item_scene: PackedScene = null
## 轨道场景引用。
@export var track_scene: PackedScene = null
## 左轨道工具栏项场景引用。
@export var left_track_tool_bar_item_scene: PackedScene = null
## 右轨道工具栏项场景引用。
@export var right_track_tool_bar_item_scene: PackedScene = null

## 选中的轨道项引用。
var selected_item: TrackEditorTrackItem = null
## 轨道项列表。
var item_list: Array[TrackEditorTrackItem] = []
## 上一次的刻度长度。
var last_tick_length: float = -1.0


func _ready() -> void:
	track_length_spin_box.value = track_length
	tick_length_spin_box.value = tick_length
	
	if hide_mouse_tool_bar:
		_hide_mouse_tool_bar()
	else:
		_show_mouse_tool_bar()

	if not multiple_track_enable:
		_hide_multiple_track_section()
	else:
		_show_multiple_track_section()
			
	if Engine.is_editor_hint():
		pass
	else:
		track_length_spin_box.value_changed.connect(_on_track_length_changed)
		tick_length_spin_box.value_changed.connect(_on_tick_length_changed)

		for _tick_index: int in ceili(track_length / tick_length):
			var tick: TrackEditorTick = tick_scene.instantiate()
			tick.track_editor = self
			ruler.add_child(tick)
		create_track()


## 获取轨道刻度像素长度。
func get_pixel_tick_length() -> float:
	var first_tick: TrackEditorTick = ruler.get_child(0)
	return first_tick.size.x


## 获取刻度单位的像素长度。
func get_pixel_per_tick() -> float:
	return get_pixel_tick_length() / tick_length


## 选中轨道项。
func select_item(item: TrackEditorTrackItem) -> void:
	Log.verbose("选择轨道项: %s" % item.index)
	selected_item = item
	item.is_selected = true
	item_selected.emit(item)


## 取消选中轨道项。
func deselect_item() -> void:
	if not selected_item:
		return

	Log.verbose("取消选中轨道项: %s" % selected_item.index)
		
	selected_item.is_selected = false
	selected_item.is_draging = false
		
	item_deselected.emit(selected_item)
	selected_item = null


## 创建轨道项。
func create_item(track_index: int = 0) -> TrackEditorTrackItem:
	Log.verbose("创建轨道项: %s" % track_index)
		
	var track_item: TrackEditorTrackItem = track_item_scene.instantiate()
	track_item.position.y = 2
	track_item.track_editor = self
	track_item.track_index = track_index

	return track_item


## 插入轨道项。
func insert_item(item: TrackEditorTrackItem, signal_emit_disabled: bool = false) -> void:
	var track: TrackEditorTrack = get_track(item.track_index)
	track.item_container.add_child(item)
	update_item_list()
	update_item_list_last_index()
	if not signal_emit_disabled:
		item_inserted.emit(item)


## 删除轨道项。
func erase_item(item: TrackEditorTrackItem) -> void:
	Log.verbose("删除轨道项: %s" % item.index)
		
	var track: TrackEditorTrack = get_track(item.track_index)
	track.item_container.remove_child(item)
	item.queue_free()
	update_item_list()
	item_deleted.emit(item)
	update_item_list_last_index()
		
	
## 获取轨道项。
func get_item(index: int, track_index: int = 0) -> TrackEditorTrackItem:
	var track: TrackEditorTrack = get_track(track_index)
	return track.item_container.get_child(index)


## 更新轨道项列表。
func update_item_list() -> void:
	item_list.clear()
	for track: TrackEditorTrack in track_vbox_container.get_children():
		for child: TrackEditorTrackItem in track.item_container.get_children():
			item_list.append(child)

	item_list.sort_custom(
		func(a: TrackEditorTrackItem, b: TrackEditorTrackItem) -> bool:
			var a_track_position_x: float = a.track_position_x
			var b_track_position_x: float = b.track_position_x

			if a_track_position_x == b_track_position_x:
				return a.track_index < b.track_index
			else:
				return a_track_position_x < b_track_position_x
	)

	for item_index: int in item_list.size():
		var item: TrackEditorTrackItem = item_list[item_index]
		item.index = item_index


func update_item_list_last_index() -> void:
	for item_index: int in item_list.size():
		var item: TrackEditorTrackItem = item_list[item_index]
		item.last_index = item_index


## 获取轨道刻度数量。
func get_tick_count() -> int:
	return ceili(track_length / tick_length)


## 获取轨道。
func get_track(track_index: int = 0) -> TrackEditorTrack:
	return track_vbox_container.get_child(track_index)
	

## 创建轨道。
func create_track() -> void:
	Log.verbose("创建轨道")
		
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
			

## 删除轨道。
func remove_track(track_index: int) -> void:
	Log.verbose("删除轨道: %s" % track_index)
		
	var track: TrackEditorTrack = get_track(track_index)
	track_vbox_container.remove_child(track)
	track.queue_free()

	if multiple_track_enable:
		var right_track_tool_bar_item: TrackEditorRightTrackToolBarItem = right_track_tool_bar.get_child(track_index)
		right_track_tool_bar.remove_child(right_track_tool_bar_item)
		right_track_tool_bar_item.queue_free()		
		var left_track_tool_bar_item: TrackEditorLeftTrackToolBarItem = left_track_tool_bar.get_child(track_index)
		left_track_tool_bar.remove_child(left_track_tool_bar_item)
		left_track_tool_bar_item.queue_free()


## 清除所有轨道。
func clear_tracks() -> void:
	Log.verbose("清除所有轨道")
		
	for track_index: int in track_vbox_container.get_child_count():
		remove_track(track_index)
		

func _hide_mouse_tool_bar() -> void:
	mouse_tool_bar.visible = false


func _show_mouse_tool_bar() -> void:
	mouse_tool_bar.visible = true


func _hide_multiple_track_section() -> void:
	add_track_button.visible = false
	left_track_tool_bar.visible = false
	right_track_tool_bar.visible = false


func _show_multiple_track_section() -> void:
	add_track_button.visible = true
	left_track_tool_bar.visible = true
	right_track_tool_bar.visible = true


func _on_track_length_changed(new_track_length: float = 0.0) -> void:
	var target_tick_count: int = ceili(new_track_length / tick_length)
	var has_tick_count: int = ruler.get_child_count()

	# 创建刻度节点
	if has_tick_count < target_tick_count:
		for _tick_index: int in range(has_tick_count, target_tick_count):
			var tick: TrackEditorTick = tick_scene.instantiate()
			tick.track_editor = self
			ruler.add_child(tick)
	elif has_tick_count > target_tick_count:
		for tick_index: int in range(target_tick_count, has_tick_count):
			var tick: TrackEditorTick = ruler.get_child(tick_index)
			tick.visible = false

	for tick_index: int in target_tick_count:
		var tick: TrackEditorTick = ruler.get_child(tick_index)
		tick.visible = true


func _on_tick_length_changed(new_value: float) -> void:
	last_tick_length = tick_length
	tick_length = new_value
