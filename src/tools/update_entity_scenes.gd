@tool
extends EditorScript
## 更新实体场景路径的工具。


## 实体场景目录路径。
const ENTITY_SCENES_DIR: String = "res://entities/"


## 实体场景。
var entity_scenes: EntityScenes = null
	

func _run() -> void:
	entity_scenes = EntityScenes.new()
	_process_scene_dir(ENTITY_SCENES_DIR)
	
	for dir_name: String in U.open_directory(ENTITY_SCENES_DIR).get_directories():
		var full_path: String = ENTITY_SCENES_DIR.path_join(dir_name)
		_process_scene_dir(full_path)
			
	ResourceSaver.save(entity_scenes, ENTITY_SCENES_DIR.path_join("entity_scenes.tres"))
	

## 处理实体场景目录。
func _process_scene_dir(dir_path: String) -> void:
	for file: String in U.open_directory(dir_path).get_files():		
		if file.get_extension() != "tscn":
			continue
			
		var full_path: String = dir_path.path_join(file)
		var scene: PackedScene = load(full_path)

		entity_scenes.scene_list.append(scene)
		Log.verbose("处理 %s" % full_path)
