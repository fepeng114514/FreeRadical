@tool
extends NodeConfig
class_name BuildComponentNodeConfig
## 建造组件节点配置资源。
##
## [BuildComponentNodeConfig] 用于存储 [BuildComponent] 的可配置数据。


## 建造时间，单位为秒。
@export var build_time: float = 1.0
## 建造目标实体。
@export_file("*.tscn") var build_target: String = ""