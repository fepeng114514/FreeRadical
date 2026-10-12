extends Resource
class_name NodeConfigTemplateNode
## 节点配置模板节点资源。
##
## [NodeConfigTemplateNode] 是一个用于存储原始 [NodeConfig] 的资源，这样就可以保存为文件，外部可以通过资源文件修改数据，实现局外升级等功能。


## 节点名称。
@export var name: String = ""
## 节点配置。
@export var config: NodeConfig = null
## 子节点数组。
@export var children: Array[NodeConfigTemplateNode] = []
## 子节点字典。
@export var children_dict: Dictionary[String, NodeConfigTemplateNode] = {}


## 获取子节点数组。
func get_children() -> Array[NodeConfigTemplateNode]:
	return children


## 添加子节点。
func add_child(child: NodeConfigTemplateNode):
	children.append(child)
	children_dict[child.name] = child


## 根据索引获取子节点的配置。
func get_child_config(node_index: int) -> NodeConfig:
	if node_index < 0 or node_index >= children.size():
		return null

	return children[node_index].config


## 根据路径获取子节点的配置。
func get_node_config(node_path: NodePath) -> NodeConfig:
	var node: NodeConfigTemplateNode = self

	for i: int in node_path.get_name_count():
		var path_name: String = node_path.get_name(i)
		if path_name == ".":
			continue

		node = node.children_dict.get(path_name)
		if not node:
			return null

	return node.config
