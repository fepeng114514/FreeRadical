@tool
extends EditorScript
## 更新实体场景路径的工具。


## 实体场景目录路径。
const ENTITY_SCENES_DIR: String = "res://entities/"


## 实体场景。
var entity_scene_path_data: EntityScenePathData = EntityScenePathData.new()
	

func _run() -> void:
	for file: String in U.get_files_from_nested_directory(ENTITY_SCENES_DIR, "*.tscn"):
		entity_scene_path_data.scene_path_dict[file.get_file().get_basename()] = file
		Log.verbose("处理 %s" % file)
			
	ResourceSaver.save(entity_scene_path_data, ENTITY_SCENES_DIR.path_join("entity_scene_path_data.tres"))
