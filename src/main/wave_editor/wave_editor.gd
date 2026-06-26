extends Control
class_name WaveEditor


@export_group("Ref")
@export var wave_track_editor: TrackEditor = null
@export var sub_wave_track_editor: TrackEditor = null
@export var spawn_track_editor: TrackEditor = null
@export var spawn_data_vbox_container: WaveEditorSpawnDataVBoxContainer = null
@export var entity_option_button_label: OptionButtonLabel = null

## 实体场景索引字典。
var entity_scene_idx_dict: Dictionary[PackedScene, int] = {}
## 实体场景列表。
var entity_scene_list: Array[PackedScene] = []
## 关卡波次组。
var wave_group: WaveGroup = null:
	get: 
		if not wave_group:
			wave_group = WaveGroup.new()
			
		return wave_group
## 选中的波次。
var selected_wave: Wave = null
## 选中的子波次。
var selected_sub_wave: SubWave = null
## 选中的波次。
var selected_spawn: WaveSpawn = null


func _ready() -> void:
	var json_data: Array = U.load_json(
		"res://entities/entity_scene_paths.json"
	)

	var entity_scene_dict: Dictionary[String, PackedScene] = {}
	
	for path: String in json_data:
		if not ResourceLoader.exists(path):
			Log.error("未找到实体场景: %s" % path)
			continue
		
		var scene: PackedScene = load(path)
		var scene_name: String = path.get_file().get_basename()
		entity_scene_dict[scene_name] = scene
		
	var i: int = 0
	for scene_name: String in entity_scene_dict:
		if not scene_name.begins_with("enemy_"):
			continue
		
		var scene: PackedScene = entity_scene_dict[scene_name]
		
		var option_item: String = scene_name.replace("enemy_", "").capitalize()
		entity_option_button_label.option_button.add_item(option_item)
		entity_scene_idx_dict[scene] = i
		entity_scene_list.append(scene)
		i += 1

	wave_track_editor.hide_sub_wave_track_editor()


## 加载关卡波次组。
func load_wave_group(path: String) -> void:
	Log.info("加载关卡波次：%s" % path)
	wave_group = load(path).duplicate(true)
	wave_track_editor.clear_tracks()
	wave_track_editor.create_track()

	var wave_list: Array[Wave] = wave_group.wave_list

	var current_time: float = 0
	for i: int in wave_list.size():
		var wave: Wave = wave_list[i]
		var track_item: TrackEditorTrackItem = wave_track_editor.create_item()

		if i != 0:
			current_time += wave.interval
			track_item.set_track_pos_x(current_time)

		wave_track_editor.insert_item(track_item, true)

	wave_track_editor.hide_sub_wave_track_editor()


## 保存关卡波次组。
func save_wave_group(path: String) -> void:
	Log.info("保存关卡波次：%s" % path)
	ResourceSaver.save(wave_group, path)


## 获取关卡波次。
func get_wave(wave_idx: int) -> Wave:
	return wave_group.wave_list[wave_idx]


## 获取子波次。
func get_sub_wave(sub_wave_idx: int) -> SubWave:
	return selected_wave.sub_wave_list[sub_wave_idx]


## 获取生成组。
func get_spawn(spawn_idx: int) -> WaveSpawn:
	return selected_sub_wave.spawn_list[spawn_idx]
