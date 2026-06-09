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
	wave_editor.spawn_track_editor.visible = false
	wave_editor.spawn_data_vbox_container.visible = false


func _on_item_select(item: TrackEditorTrackItem) -> void:
	var sub_wave: SubWave = wave_editor.get_sub_wave(item.idx)
	wave_editor.selected_sub_wave = sub_wave
	var spawn_track_editor: TrackEditor = wave_editor.spawn_track_editor
	spawn_track_editor.clear_tracks()
	spawn_track_editor.create_track()

	var current_time: float = 0.0
	var spawn_list: Array[WaveSpawn] = sub_wave.spawn_list
	
	for i: int in spawn_list.size():
		var spawn: WaveSpawn = spawn_list[i]
		current_time += spawn.interval
		var track_item: TrackEditorTrackItem = spawn_track_editor.create_item()
		track_item.set_pos_by_track_pos(current_time)
		spawn_track_editor.insert_item(track_item, true)

	spawn_track_editor.visible = true


func _on_item_deselect(_item: TrackEditorTrackItem) -> void:
	_hide_sub_track_editor()


func _on_item_insert(item: TrackEditorTrackItem) -> void:
	var new_sub_wave := SubWave.new()
	new_sub_wave.delay = item.track_pos
	wave_editor.selected_wave.sub_wave_list.append(new_sub_wave)


func _on_item_delete(item: TrackEditorTrackItem) -> void:
	wave_editor.selected_wave.sub_wave_list.remove_at(item.idx)
	_hide_sub_track_editor()


func _on_item_move(item: TrackEditorTrackItem) -> void:
	wave_editor.get_sub_wave(item.idx).delay = item.track_pos
	

func _on_item_order_changed() -> void:
	var new_sub_wave_list_size: int = wave_editor.selected_wave.sub_wave_list.size()
	if new_sub_wave_list_size != item_list.size():
		return

	var new_sub_wave_list: Array[SubWave] = []
	new_sub_wave_list.resize(new_sub_wave_list_size)

	for i: int in new_sub_wave_list_size:
		var item: TrackEditorTrackItem = item_list[i]
		new_sub_wave_list[i] = wave_editor.get_sub_wave(item.last_idx)

	wave_editor.selected_wave.sub_wave_list = new_sub_wave_list
