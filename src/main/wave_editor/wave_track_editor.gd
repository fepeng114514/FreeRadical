extends TrackEditor


@export var wave_editor: WaveEditor = null


func _ready() -> void:
	super()
	item_selected.connect(_on_item_selected)
	item_deselected.connect(_on_item_deselected)
	item_inserted.connect(_on_item_inserted)
	item_deleted.connect(_on_item_deleted)
	item_moved.connect(_on_item_moved)


func hide_sub_wave_track_editor() -> void:
	wave_editor.sub_wave_track_editor.visible = false
	wave_editor.spawn_track_editor.visible = false
	wave_editor.spawn_data_vbox_container.visible = false
	

func _on_item_selected(item: TrackEditorTrackItem) -> void:
	var wave: Wave = wave_editor.get_wave(item.idx)
	wave_editor.selected_wave = wave

	var sub_wave_track_editor: TrackEditor = wave_editor.sub_wave_track_editor
	sub_wave_track_editor.clear_tracks()

	var sub_wave_list: Array[SubWave] = wave.sub_wave_list

	if not sub_wave_list:
		sub_wave_track_editor.create_track()
	else:
		sub_wave_list.sort_custom(
			func(a: SubWave, b: SubWave) -> bool:
				return a.delay < b.delay
		)

	var delay_use_count_dict: Dictionary[float, int] = {}
	
	for i: int in sub_wave_list.size():
		var sub_wave: SubWave = sub_wave_list[i]
		var delay: float = sub_wave.delay

		if not delay_use_count_dict.has(delay):
			delay_use_count_dict[delay] = 0

		delay_use_count_dict[delay] += 1

		var use_count: int = delay_use_count_dict[delay]

		if sub_wave_track_editor.track_vbox_container.get_child_count() < use_count:
			sub_wave_track_editor.create_track()
		
		var track_item: TrackEditorTrackItem = sub_wave_track_editor.create_item(use_count - 1)
		track_item.set_track_pos_x(delay)
		sub_wave_track_editor.insert_item(track_item, true)

	sub_wave_track_editor.visible = true


func _on_item_deselected(_item: TrackEditorTrackItem) -> void:
	hide_sub_wave_track_editor()


func _on_item_inserted(item: TrackEditorTrackItem) -> void:
	var wave := Wave.new()
	wave.interval = item.get_relative_track_pos_x()
	wave_editor.wave_group.wave_list.insert(item.idx, wave)
	_update_interval()


func _on_item_deleted(item: TrackEditorTrackItem) -> void:
	if wave_editor.get_wave(item.idx) == wave_editor.selected_wave:
		hide_sub_wave_track_editor()
		
	wave_editor.wave_group.wave_list.remove_at(item.idx)
	_update_interval()


func _on_item_moved(_item: TrackEditorTrackItem) -> void:
	_update_wave_list()


func _update_wave_list() -> void:
	var item_list_size: int = item_list.size()
	var new_wave_list: Array[Wave] = []
	new_wave_list.resize(item_list_size)

	for i: int in item_list_size:
		var item: TrackEditorTrackItem = item_list[i]
		var last_wave: Wave = wave_editor.get_wave(item.last_idx)
		new_wave_list[i] = last_wave

	wave_editor.wave_group.wave_list = new_wave_list
	_update_interval()


func _update_interval() -> void:
	for i: int in item_list.size():
		var item: TrackEditorTrackItem = item_list[i]
		var wave: Wave = wave_editor.get_wave(i)
		wave.interval = item.get_relative_track_pos_x()
