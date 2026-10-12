@tool
extends NodeConfig
class_name DurationComponentNodeConfig
## 持续时间组件节点配置。
##
## [DurationComponentNodeConfig] 用于存储 [DurationComponent] 的可配置数据。


## 持续时间（秒），-1 表示无限。
@export var duration: float = -1