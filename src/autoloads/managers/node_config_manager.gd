@tool
extends Node
## 节点配置管理器。


const NODE_CONFIG_TEMPLATE_DATA_PATH: String = "res://data/node_config_template_data.tres"


var node_config_template_data: NodeConfigTemplateData = null


func _ready() -> void:
	init()


## 初始化节点配置管理器。
func init() -> void:
	node_config_template_data = load(NODE_CONFIG_TEMPLATE_DATA_PATH)


## 清理节点配置管理器。
func cleanup() -> void:
	node_config_template_data = null


func get_common_configuration_warnings(node: Node) -> PackedStringArray:
	var warnings := PackedStringArray()

	var config := node.config as NodeConfig

	if not config:
		warnings.append("请设置一个 config 节点配置，或点击实体的 “更新节点配置模板” 按钮一键生成。")

	if config:
		if not FileAccess.file_exists(config.resource_path):
			warnings.append("请将 config 节点配置保存为文件，否则后续无法在节点配置管理器中索引该实体的节点配置。")

	return warnings