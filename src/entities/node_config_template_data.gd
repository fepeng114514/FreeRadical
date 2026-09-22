@tool
extends Resource
class_name NodeConfigTemplateData
## 节点配置模板数据，存储所有实体的节点配置模板。


## 实体名到节点配置模板节点映射。
@export var entity_name_to_template_map: Dictionary[String, NodeConfigTemplateNode] = {}
