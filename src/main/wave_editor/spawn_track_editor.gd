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
	wave_editor.spawn_data_vbox_container.visible = false


func _on_item_selected(item: TrackEditorTrackItem) -> void:
	var spawn: WaveSpawn = wave_editor.get_spawn(item.idx)
	wave_editor.selected_spawn = spawn
	
	var spawn_data_vbox_container: WaveEditorSpawnDataVBoxContainer = wave_editor.spawn_data_vbox_container
	spawn_data_vbox_container.set_spawn_data(spawn)
	spawn_data_vbox_container.visible = true


func _on_item_deselected(_item: TrackEditorTrackItem) -> void:
	_hide_sub_track_editor()


func _on_item_inserted(item: TrackEditorTrackItem) -> void:
	var new_spawn := WaveSpawn.new()
	new_spawn.entity = wave_editor.entity_scene_list[0]
	new_spawn.interval = item.get_relative_track_pos_x()
	wave_editor.selected_sub_wave.spawn_list.insert(item.idx, new_spawn)
	_update_interval()


func _on_item_deleted(item: TrackEditorTrackItem) -> void:
	wave_editor.selected_sub_wave.spawn_list.remove_at(item.idx)
	_update_interval()

	_hide_sub_track_editor()


func _on_item_moved(_item: TrackEditorTrackItem) -> void:
	_update_spawn_list()

		
func _update_spawn_list() -> void:
	var item_list_size: int = item_list.size()
	var new_spawn_list: Array[WaveSpawn] = []
	new_spawn_list.resize(item_list_size)

	for i: int in item_list_size:
		var item: TrackEditorTrackItem = item_list[i]
		var last_spawn: WaveSpawn = wave_editor.get_spawn(item.last_idx)
		new_spawn_list[i] = last_spawn

	wave_editor.selected_sub_wave.spawn_list = new_spawn_list
	_update_interval()


func _update_interval() -> void:
	for i: int in item_list.size():
		var item: TrackEditorTrackItem = item_list[i]
		var spawn: WaveSpawn = wave_editor.get_spawn(i)
		spawn.interval = item.get_relative_track_pos_x()
