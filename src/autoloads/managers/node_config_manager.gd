@tool
extends Node
## 节点配置管理器。
## 
## [NodeConfigManager] 负责管理节点配置模板与相关操作。


## 节点配置模板数据路径。
const NODE_CONFIG_TEMPLATE_DATA_PATH: String = "res://data/node_config_template_data.tres"

var _node_config_template_data: NodeConfigTemplateData = null


func _ready() -> void:
	init()


## 初始化节点配置管理器。
func init() -> void:
	_node_config_template_data = load(NODE_CONFIG_TEMPLATE_DATA_PATH)


## 清理节点配置管理器。
func cleanup() -> void:
	_node_config_template_data = null


## 通过实体名称获取实体的节点配置模板。
func get_node_config_template_by_entity_name(entity_name: String) -> NodeConfigTemplateNode:
	return _node_config_template_data.entity_name_to_template_map[entity_name]


## 通过实体路径获取实体的节点配置模板。
func get_node_config_template_by_entity_path(entity_path: String) -> NodeConfigTemplateNode:
	return _node_config_template_data.entity_path_to_template_map[entity_path]


## 通过实体UID获取实体的节点配置模板。
func get_node_config_template_by_entity_uid(entity_uid: String) -> NodeConfigTemplateNode:
	return _node_config_template_data.entity_uid_to_template_map[entity_uid]


## 获取节点的通用配置警告。
func get_common_configuration_warnings(node: Node) -> PackedStringArray:
	var warnings := PackedStringArray()

	var config_prop: Dictionary = {}
	for prop: Dictionary in node.get_property_list():
		if prop.name != "config":
			continue

		config_prop = prop
		break

	if config_prop:
		var config: NodeConfig = node.config
		if config:
			if not FileAccess.file_exists(config.resource_path):
				warnings.append("不推荐手动设置配置：\n如果想要手动设置配置，请将 config 节点配置保存为文件，然后在实体的 node_config_template 配置模板中创建节点。\n否则请清除当前配置然后点击实体的 “更新节点配置模板” 按钮一键生成。")
		else:
			warnings.append("请设置一个 config 节点配置，或点击实体的 “更新节点配置模板” 按钮一键生成。")

	return warnings
