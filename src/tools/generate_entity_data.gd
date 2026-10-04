@tool
extends EditorScript
## 生成实体场景路径数据的工具。


## 实体场景目录路径。
const ENTITY_SCENES_DIR: String = "res://entities/"
const DATA_DIR: String = "res://data/"


func _run() -> void:
	var entity_scene_states: Array[SceneState] = []
	
	for file: String in Utils.get_files_from_nested_directory(ENTITY_SCENES_DIR, "*.tscn"):
		var scene: PackedScene = load(file)
		var state: SceneState = scene.get_state()
		entity_scene_states.append(state)
		
	_generate_entity_data(entity_scene_states)
	_generate_node_config_template_data(entity_scene_states)


func _generate_entity_data(entity_scene_states: Array[SceneState]) -> void:
	var entity_scene_data := EntitySceneData.new()

	for state: SceneState in entity_scene_states:
		var scene_file_path: String = state.get_path()
		var scene_basename: String = scene_file_path.get_file().get_basename()
		var scene_uid: String = ResourceUID.path_to_uid(scene_file_path)

		entity_scene_data.entity_name_to_path_map[scene_basename] = scene_file_path
		entity_scene_data.entity_name_to_uid_map[scene_basename] = scene_uid

		Log.verbose("添加实体场景数据: %s, UID: %s" % [scene_basename, scene_uid])
			
	var save_path = DATA_DIR.path_join("entity_scene_data.tres")
	ResourceSaver.save(entity_scene_data, save_path)
	Log.info("已生成实体场景数据: %s" % save_path)


func _generate_node_config_template_data(entity_scene_states: Array[SceneState]) -> void:
	const ROOT_NODE_INDEX: int = 0

	var node_config_template_data := NodeConfigTemplateData.new()

	for state: SceneState in entity_scene_states:
		var entity_name: String = state.get_path().get_file().get_basename()

		for prop_index: int in state.get_node_property_count(ROOT_NODE_INDEX):
			var prop_name: String = state.get_node_property_name(ROOT_NODE_INDEX, prop_index)
			if prop_name != "node_config_template":
				continue

			var config_template: NodeConfigTemplateNode = state.get_node_property_value(ROOT_NODE_INDEX, prop_index)
			node_config_template_data.entity_name_to_template_map[entity_name] = config_template

			var scene_path: String = state.get_path()
			var scene_uid: String = ResourceUID.path_to_uid(scene_path)
			node_config_template_data.entity_path_to_template_map[scene_path] = config_template
			node_config_template_data.entity_uid_to_template_map[scene_uid] = config_template

			Log.verbose("添加节点配置模板数据: %s, UID: %s" % [entity_name, scene_uid])
			break

	var save_path = DATA_DIR.path_join("node_config_template_data.tres")
	ResourceSaver.save(node_config_template_data, save_path)
	Log.info("已生成节点配置模板数据: %s" % save_path)
