extends Control
class_name WaveEditor


@export_group("Ref")
@export var wave_track_editor: TrackEditor = null
@export var sub_wave_track_editor: TrackEditor = null
@export var spawn_track_editor: TrackEditor = null
@export var spawn_data_vbox_container: WaveEditorSpawnDataVBoxContainer = null
@export var entity_option_button_label: OptionButtonLabel = null

var entity_name_dict: Dictionary[String, String] = {}
var entity_name_idx_dict: Dictionary[String, int] = {}
var wave_group: WaveGroup = null
var selected_wave: Wave = null
var selected_sub_wave: SubWave = null
var selected_spawn: WaveSpawn = null


func _ready() -> void:
	var entity_scene_dict: Dictionary[String, PackedScene] = EntityMgr.load_entity_scene()

	var i: int = 0
	for scene_name: String in entity_scene_dict:
		if not scene_name.begins_with("enemy_"):
			continue
		
		entity_name_dict[scene_name] = scene_name
		entity_option_button_label.option_button.add_item(scene_name)
		entity_name_idx_dict[scene_name] = i
		i += 1
		
	sub_wave_track_editor.visible = false
	spawn_track_editor.visible = false
	spawn_data_vbox_container.visible = false

	wave_track_editor.item_select.connect(_on_wave_track_editor_item_select)
	wave_track_editor.item_deselect.connect(_on_wave_track_editor_item_deselect)
	wave_track_editor.item_order_changed.connect(_on_wave_track_editor_item_order_changed)
	sub_wave_track_editor.item_select.connect(_on_sub_wave_track_editor_item_select)
	sub_wave_track_editor.item_deselect.connect(_on_sub_wave_track_editor_item_deselect)
	sub_wave_track_editor.item_order_changed.connect(_on_sub_wave_track_editor_item_order_changed)
	spawn_track_editor.item_order_changed.connect(_on_spawn_track_editor_item_order_changed)
	spawn_track_editor.item_select.connect(_on_spawn_track_editor_item_select)
	spawn_track_editor.item_deselect.connect(_on_spawn_track_editor_item_deselect)


func load_wave_group(path: String) -> void:
	Log.info("加载关卡波次：%s" % path)
	wave_group = load(path).duplicate(true)
	load_waves()


func load_waves() -> void:
	wave_track_editor.clear_tracks()
	wave_track_editor.create_track()

	var wave_list: Array[Wave] = wave_group.wave_list

	var current_time: float = 0
	for i: int in wave_list.size():
		var wave: Wave = wave_list[i]
		var track_item: TrackEditorTrackItem = wave_track_editor.create_item()

		if i != 0:
			current_time += wave.interval
			track_item.set_pos_by_track_pos(current_time)
	
	wave_track_editor.update_item_list()


func _load_sub_wave() -> void:
	sub_wave_track_editor.clear_tracks()
	var sub_wave_list: Array[SubWave] = selected_wave.sub_wave_list
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
	
	sub_wave_track_editor.update_item_list()


func _load_spawn() -> void:
	spawn_track_editor.clear_tracks()
	spawn_track_editor.create_track()

	var current_time: float = 0.0
	var spawn_list: Array[WaveSpawn] = selected_sub_wave.spawn_list
	
	for i: int in spawn_list.size():
		var spawn: WaveSpawn = spawn_list[i]
		current_time += spawn.interval
		var track_item: TrackEditorTrackItem = spawn_track_editor.create_item()
		track_item.set_pos_by_track_pos(current_time)
	
	spawn_track_editor.update_item_list()


func _on_wave_track_editor_item_select(item: TrackEditorTrackItem) -> void:
	selected_wave = wave_group.wave_list[item.idx]
	_load_sub_wave()
	sub_wave_track_editor.visible = true


func _on_wave_track_editor_item_deselect() -> void:
	sub_wave_track_editor.visible = false
	spawn_track_editor.visible = false
	spawn_data_vbox_container.visible = false


func _on_wave_track_editor_item_order_changed() -> void:
	var wave_list_size: int = wave_group.wave_list.size()

	var new_wave_list: Array[Wave] = []
	new_wave_list.resize(wave_list_size)

	for i: int in wave_list_size:
		var item: TrackEditorTrackItem = wave_track_editor.item_list[i]
		new_wave_list[i] = wave_group.wave_list[item.last_idx]

	wave_group.wave_list = new_wave_list


func _on_sub_wave_track_editor_item_select(item: TrackEditorTrackItem) -> void:
	selected_sub_wave = selected_wave.sub_wave_list[item.idx]
	_load_spawn()
	spawn_track_editor.visible = true


func _on_sub_wave_track_editor_item_deselect() -> void:
	spawn_track_editor.visible = false
	spawn_data_vbox_container.visible = false


func _on_sub_wave_track_editor_item_order_changed() -> void:
	var new_sub_wave_list_size: int = selected_wave.sub_wave_list.size()

	var new_sub_wave_list: Array[SubWave] = []
	new_sub_wave_list.resize(new_sub_wave_list_size)

	for i: int in new_sub_wave_list_size:
		var item: TrackEditorTrackItem = sub_wave_track_editor.item_list[i]
		new_sub_wave_list[i] = selected_wave.sub_wave_list[item.last_idx]

	selected_wave.sub_wave_list = new_sub_wave_list


func _on_spawn_track_editor_item_select(item: TrackEditorTrackItem) -> void:
	selected_spawn = selected_sub_wave.spawn_list[item.idx]
	spawn_data_vbox_container.interval.value = selected_spawn.interval
	spawn_data_vbox_container.entity.option_button.select(entity_name_idx_dict[selected_spawn.entity])
	spawn_data_vbox_container.pathway.value = selected_spawn.pathway_idx
	spawn_data_vbox_container.sub_pathway.value = selected_spawn.sub_pathway_idx
	spawn_data_vbox_container.count.value = selected_spawn.count
	spawn_data_vbox_container.interval.value = selected_spawn.spawn_interval
	spawn_data_vbox_container.reversed.button_pressed = selected_spawn.reversed
	spawn_data_vbox_container.loop.button_pressed = selected_spawn.loop
	spawn_data_vbox_container.visible = true


func _on_spawn_track_editor_item_deselect() -> void:
	spawn_data_vbox_container.visible = false


func _on_spawn_track_editor_item_order_changed() -> void:
	var spawn_list_size: int = selected_sub_wave.spawn_list.size()

	var new_spawn_list: Array[WaveSpawn] = []
	new_spawn_list.resize(spawn_list_size)

	for i: int in spawn_list_size:
		var item: TrackEditorTrackItem = spawn_track_editor.item_list[i]
		new_spawn_list[i] = selected_sub_wave.spawn_list[item.last_idx]

	selected_sub_wave.spawn_list = new_spawn_list
