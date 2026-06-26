extends TrackEditor


@export var wave_editor: WaveEditor = null


func _ready() -> void:
	super()
	item_selected.connect(_on_item_selected)
	item_deselected.connect(_on_item_deselected)
	item_inserted.connect(_on_item_inserted)
	item_deleted.connect(_on_item_deleted)
	item_moved.connect(_on_item_moved)


func _hide_sub_track_editor() -> void:
	wave_editor.spawn_track_editor.visible = false
	wave_editor.spawn_data_vbox_container.visible = false


func _on_item_selected(item: TrackEditorTrackItem) -> void:
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
		track_item.set_track_pos_x(current_time)
		spawn_track_editor.insert_item(track_item, true)

	spawn_track_editor.visible = true


func _on_item_deselected(_item: TrackEditorTrackItem) -> void:
	_hide_sub_track_editor()


func _on_item_inserted(item: TrackEditorTrackItem) -> void:
	var sub_wave := SubWave.new()
	sub_wave.delay = item.track_pos_x
	wave_editor.selected_wave.sub_wave_list.insert(item.idx, sub_wave)


func _on_item_deleted(item: TrackEditorTrackItem) -> void:
	if wave_editor.get_sub_wave(item.idx) == wave_editor.selected_sub_wave:
		_hide_sub_track_editor()
		
	wave_editor.selected_wave.sub_wave_list.remove_at(item.idx)


func _on_item_moved(item: TrackEditorTrackItem) -> void:
	wave_editor.get_sub_wave(item.idx).delay = item.track_pos_x
	_update_sub_wave_list()


func _update_sub_wave_list() -> void:
	var item_list_size: int = item_list.size()
	var new_sub_wave_list: Array[SubWave] = []
	new_sub_wave_list.resize(item_list_size)

	for i: int in item_list_size:
		var item: TrackEditorTrackItem = item_list[i]
		var last_sub_wave: SubWave = wave_editor.get_sub_wave(item.last_idx)
		new_sub_wave_list[i] = last_sub_wave

	wave_editor.selected_wave.sub_wave_list = new_sub_wave_list
