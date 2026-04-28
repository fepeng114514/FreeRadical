@tool
extends EditorScript
#class_name UpdateJsonDatas
## 更新 "res://datas/" 目录的 JSON

const DIR_ENTITY_SCENES: String = "res://scenes/entities/"


func _run() -> void:
	_updata_entity_scene_paths()
	

## 更新 entity_scene_paths
func _updata_entity_scene_paths() -> void:
	var dir_entity_scenes: DirAccess = U.open_directory(
		DIR_ENTITY_SCENES
	)
	var entity_scene_paths: Dictionary[String, String] = {}
	
	for scene_file: String in dir_entity_scenes.get_files():		
		if scene_file.get_extension() != "tscn":
			continue
			
		var full_path: String = DIR_ENTITY_SCENES.path_join(scene_file)
		entity_scene_paths[scene_file.get_basename()] = full_path
		Log.verbose("处理 %s" % full_path)
			
	U.save_json(
		entity_scene_paths, 
		"res://datas/%s.json" % "entity_scenes"
	)
