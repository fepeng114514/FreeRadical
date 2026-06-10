extends PanelContainer
class_name TrackEditor
## 轨道编辑器。
##
## TrackEditor 适用于时间轴可视化编辑等场景。


@warning_ignore_start("unused_signal")
## 项选中信号。
signal item_select(item: TrackEditorTrackItem)
## 项取消选中信号。
signal item_deselect(item: TrackEditorTrackItem)
## 项插入信号。
signal item_insert(item: TrackEditorTrackItem)
## 项删除信号。
signal item_delete(item: TrackEditorTrackItem)
## 项移动信号。
signal item_move(item: TrackEditorTrackItem)
## 项顺序改变信号。
signal item_order_changed
@warning_ignore_restore("unused_signal")


## 轨道长度。
@export var track_length: float = 1000:
	set(v): 
		track_length = v
		if track_length_spin_box:
			track_length_spin_box.value = v
## 轨道刻度间距。
@export var tick_spacing: float = 10:
	set(v): 
		tick_spacing = v
		if tick_spacing_spin_box:
			tick_spacing_spin_box.value = v
## 项拖动时的吸附阈值。
@export var snap_threshold: float = 4
## 是否显示项顺序标签。
@export var show_item_order_label: bool = true
## 项顺序标签格式。
@export var order_label_format: String = "%d"
## 是否隐藏鼠标工具栏。
@export var hide_mouse_tool_bar: bool = false

@export_group("Multiple Track")
## 是否启用多轨道模式。
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var multiple_track_enable: bool = false

@export_group("Ref")
## 轨道长度旋钮引用。
@export var track_length_spin_box: SpinBox = null
## 轨道刻度间距数值调节框引用。
@export var tick_spacing_spin_box: SpinBox = null
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
## 轨道刻度宽度。
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


## 选中轨道项。
func select_item(item: TrackEditorTrackItem) -> void:
	Log.info("选择轨道项: %s" % item.idx)
	selected_item = item
	item.is_selected = true
	item_select.emit(item)


## 取消选中轨道项。
func deselect_item() -> void:
	if not selected_item:
		return

	Log.info("取消选中轨道项: %s" % selected_item.idx)
		
	selected_item.is_selected = false
	selected_item.is_draging = false
		
	item_deselect.emit(selected_item)
	selected_item = null


## 创建轨道项。
func create_item(track_idx: int = 0) -> TrackEditorTrackItem:
	Log.info("创建轨道项: %s" % track_idx)
		
	var track_item: TrackEditorTrackItem = track_item_scene.instantiate()
	track_item.position.y = 2
	track_item.track_editor = self
	track_item.track_idx = track_idx

	return track_item


## 插入轨道项。
func insert_item(item: TrackEditorTrackItem, signal_emit_disabled: bool = false) -> void:
	var track: TrackEditorTrack = get_track(item.track_idx)
	track.item_container.add_child(item)
	update_item_list()
	if not signal_emit_disabled:
		item_insert.emit(item)


## 删除轨道项。
func erase_item(item: TrackEditorTrackItem) -> void:
	Log.info("删除轨道项: %s" % item.idx)
		
	var track: TrackEditorTrack = get_track(item.track_idx)
	track.item_container.remove_child(item)
	item.queue_free()
	update_item_list()
	item_delete.emit(item)
		
	
## 获取轨道项。
func get_item(idx: int, track_idx: int = 0) -> TrackEditorTrackItem:
	var track: TrackEditorTrack = get_track(track_idx)
	return track.item_container.get_child(idx)


## 更新轨道项列表。
func update_item_list() -> void:
	var new_item_list: Array[TrackEditorTrackItem] = []

	for track: TrackEditorTrack in track_vbox_container.get_children():
		for child: TrackEditorTrackItem in track.item_container.get_children():
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


## 获取轨道刻度数量。
func get_tick_count() -> int:
	return ceili(track_length_spin_box.value / tick_spacing_spin_box.value)


## 获取轨道。
func get_track(track_idx: int = 0) -> TrackEditorTrack:
	return track_vbox_container.get_child(track_idx)
	

## 创建轨道。
func create_track() -> void:
	Log.info("创建轨道")
		
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
func remove_track(track_idx: int = 0) -> void:
	Log.info("删除轨道: %s" % track_idx)
		
	var track: TrackEditorTrack = get_track(track_idx)
	track_vbox_container.remove_child(track)
	track.queue_free()

	if multiple_track_enable:
		var right_track_tool_bar_item: TrackEditorRightTrackToolBarItem = right_track_tool_bar.get_child(track_idx)
		right_track_tool_bar.remove_child(right_track_tool_bar_item)
		right_track_tool_bar_item.queue_free()		
		var left_track_tool_bar_item: TrackEditorLeftTrackToolBarItem = left_track_tool_bar.get_child(track_idx)
		left_track_tool_bar.remove_child(left_track_tool_bar_item)
		left_track_tool_bar_item.queue_free()


## 清除所有轨道。
func clear_tracks() -> void:
	Log.info("清除所有轨道")
		
	for i: int in track_vbox_container.get_child_count():
		remove_track(0)
		

## 显示轨道刻度。
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
