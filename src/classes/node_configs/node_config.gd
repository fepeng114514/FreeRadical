@tool
@abstract
extends Resource
class_name NodeConfig
## 节点配置资源基类。
##
## [NodeConfig] 是所有节点配置资源的基类，用于将一些可配置的数据存储到资源中，然后在 [NodeConfigTemplateNode] 中引用。


func _init() -> void:
	resource_local_to_scene = true
