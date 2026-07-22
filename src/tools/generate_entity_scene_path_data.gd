@tool
extends EditorScript
## 生成实体场景路径数据的工具。


## 实体场景目录路径。
const ENTITY_SCENES_DIR: String = "res://entities/"


## 实体场景。
var entity_scene_path_data: EntityScenePathData = null
	

func _run() -> void:
	entity_scene_path_data = EntityScenePathData.new()
	
	for file: String in U.get_files_from_nested_directory(ENTITY_SCENES_DIR, "*.tscn"):
		var scene_name: String = file.get_file().get_basename()
		entity_scene_path_data.scene_path_dict[scene_name] = file

		var scene_uid: String = ResourceUID.path_to_uid(file)
		entity_scene_path_data.scene_uid_dict[scene_name] = scene_uid

		Log.verbose("添加实体场景路径: %s, UID: %s" % [scene_name, scene_uid])
			
	var save_path = ENTITY_SCENES_DIR.path_join("entity_scene_path_data.tres")
	ResourceSaver.save(entity_scene_path_data, save_path)
	Log.verbose("实体场景路径数据已生成: %s" % save_path)
