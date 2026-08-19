extends Control
class_name WaveEditor


@export_group("Ref")
@export var entity_scene_path_data: EntityScenePathData = null
@export var wave_track_editor: TrackEditor = null
@export var sub_wave_track_editor: TrackEditor = null
@export var spawn_track_editor: TrackEditor = null
@export var spawn_data_vbox_container: WaveEditorSpawnDataVBoxContainer = null
@export var entity_option_button_label: LabeledOptionButton = null

## 敌人场景路径到索引的映射。
var enemy_idx_dict: Dictionary[String, int] = {}
## 索引到敌人场景路径的映射。
var enemy_scene_dict: Dictionary[int, String] = {}
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
## 选中的生成组。
var selected_spawn: WaveSpawn = null


func _ready() -> void:
	var i: int = 0
	for scene_uid: String in entity_scene_path_data.scene_uid_dict.values():
		var scene_path: String = ResourceUID.uid_to_path(scene_uid)
		var scene_name: String = scene_path.get_file().get_basename()
		if not scene_name.begins_with("enemy_"):
			continue
		
		var option_item: String = tr(scene_name.to_upper())
		entity_option_button_label.option_button.add_item(option_item)
		
		enemy_idx_dict[scene_uid] = i
		enemy_scene_dict[i] = scene_uid
		i += 1

	wave_track_editor.hide_sub_wave_track_editor()


## 加载关卡波次组。
func load_wave_group(path: String) -> void:
	Log.info("加载关卡波次：%s" % path)
	wave_group = load(path).duplicate(true)
	wave_track_editor.clear_tracks()
	wave_track_editor.create_track()

	var wave_list: Array[Wave] = wave_group.wave_list

	var current_time: float = 0.0
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
