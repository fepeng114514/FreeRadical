extends TrackEditor


@export var wave_editor: WaveEditor = null


func _ready() -> void:
	super()
	item_select.connect(_on_item_select)
	item_deselect.connect(_on_item_deselect)
	item_insert.connect(_on_item_insert)
	item_delete.connect(_on_item_delete)
	item_move.connect(_on_item_move)
	item_order_changed.connect(_on_item_order_changed)


func _hide_sub_track_editor() -> void:
	wave_editor.sub_wave_track_editor.visible = false
	wave_editor.spawn_track_editor.visible = false
	wave_editor.spawn_data_vbox_container.visible = false
	

func _on_item_select(item: TrackEditorTrackItem) -> void:
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
		track_item.set_pos_by_track_pos(delay)
		sub_wave_track_editor.insert_item(track_item, true)

	sub_wave_track_editor.visible = true


func _on_item_deselect(_item: TrackEditorTrackItem) -> void:
	_hide_sub_track_editor()


func _on_item_insert(item: TrackEditorTrackItem) -> void:
	var last_item: TrackEditorTrackItem = item_list[item.idx - 1]

	var new_wave := Wave.new()
	new_wave.interval = item.track_pos - last_item.track_pos
	wave_editor.wave_group.wave_list.append(new_wave)


func _on_item_delete(item: TrackEditorTrackItem) -> void:
	wave_editor.wave_group.wave_list.remove_at(item.idx)
	_hide_sub_track_editor()


func _on_item_move(item: TrackEditorTrackItem) -> void:
	var last_item: TrackEditorTrackItem = item_list[item.idx - 1]
	wave_editor.get_wave(item.idx).interval = item.track_pos - last_item.track_pos


func _on_item_order_changed() -> void:
	var wave_list_size: int = wave_editor.wave_group.wave_list.size()
	if wave_list_size != item_list.size():
		return

	var new_wave_list: Array[Wave] = []
	new_wave_list.resize(wave_list_size)

	for i: int in wave_list_size:
		var item: TrackEditorTrackItem = item_list[i]
		new_wave_list[i] = wave_editor.get_wave(item.last_idx)

	wave_editor.wave_group.wave_list = new_wave_list
