extends TrackEditor


@export var wave_editor: WaveEditor = null


func _ready() -> void:
	super()
	item_order_changed.connect(_on_item_order_changed)
	item_select.connect(_on_item_select)
	item_deselect.connect(_on_item_deselect)
	item_insert.connect(_on_item_insert)
	item_delete.connect(_on_item_delete)



func _on_item_select(item: TrackEditorTrackItem) -> void:
	wave_editor.selected_spawn = wave_editor.get_spawn(item.idx)
	
	var spawn_data_vbox_container: WaveEditorSpawnDataVBoxContainer = wave_editor.spawn_data_vbox_container
	spawn_data_vbox_container.set_spawn_data(wave_editor.selected_spawn)
	spawn_data_vbox_container.visible = true


func _on_item_deselect() -> void:
	wave_editor.spawn_data_vbox_container.visible = false


func _on_item_order_changed() -> void:
	var spawn_list_size: int = wave_editor.selected_sub_wave.spawn_list.size()

	var new_spawn_list: Array[WaveSpawn] = []
	new_spawn_list.resize(spawn_list_size)

	for i: int in spawn_list_size:
		var item: TrackEditorTrackItem = item_list[i]
		new_spawn_list[i] = wave_editor.get_spawn(item.last_idx)

	wave_editor.selected_sub_wave.spawn_list = new_spawn_list


func _on_item_insert(item: TrackEditorTrackItem) -> void:
	var last_item: TrackEditorTrackItem = item_list[item.idx - 1]

	var new_spawn := WaveSpawn.new()
	new_spawn.interval = item.track_pos - last_item.track_pos
	wave_editor.selected_sub_wave.spawn_list.append(new_spawn)


func _on_item_delete(item: TrackEditorTrackItem) -> void:
	wave_editor.selected_sub_wave.spawn_list.remove_at(item.idx)
