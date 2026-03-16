class_name UpdateJsonDatas
## 更新 "res://datas/" 目录的 JSON

const DIR_ENTITY_SCENES: String = "res://scenes/entities/"
const DIR_AUDIOS: String = "res://assets/audios/"

func _run() -> void:
	_updata_entity_scene_paths()
	_updata_audio_paths()
	

## 更新 entity_scene_paths
func _updata_entity_scene_paths() -> void:
	var dir_entity_scenes: DirAccess = U.open_directory(
		DIR_ENTITY_SCENES
	)
	var entity_scene_paths: Array[String] = []
	
	# 1. 先处理顶层文件
	for scene_file: String in dir_entity_scenes.get_files():		
		if scene_file.get_extension() != "tscn":
			continue
			
		var full_path: String = DIR_ENTITY_SCENES.path_join(scene_file)
		entity_scene_paths.append(full_path)
		
	# 2. 处理目录
	for scene_dir: String in dir_entity_scenes.get_directories():
		var scene_dir_full_path: String = DIR_ENTITY_SCENES.path_join(
			scene_dir
		)
		var dir_subdir: DirAccess = U.open_directory(scene_dir_full_path)
		
		for scene_file: String in dir_subdir.get_files():
			if scene_file.get_extension() != "tscn":
				continue
				
			var full_path: String = scene_dir_full_path.path_join(
				scene_file
			)
			entity_scene_paths.append(full_path)
			
	# 3. 保存
	U.save_json(
		entity_scene_paths, 
		"res://datas/%s.json" % "entity_scene_paths"
	)

func _updata_audio_paths() -> void:
	var dir_audio_paths: DirAccess = U.open_directory(DIR_AUDIOS)
	var audio_paths: Array[String] = []
	
	# 1. 处理顶层文件
	for audio_file: String in dir_audio_paths.get_files():		
		if audio_file.get_extension() != "ogg":
			continue
			
		var full_path: String = (
			DIR_AUDIOS.path_join(audio_file)
		)
		audio_paths.append(full_path)
		
	# 2. 保存
	U.save_json(
		audio_paths, 
		"res://datas/%s.json" % "audio_paths"
	)
