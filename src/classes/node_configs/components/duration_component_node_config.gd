@tool
extends NodeConfig
class_name DurationComponentNodeConfig
## 持续时间组件节点配置。
##
## DurationComponentNodeConfig 可以配置持续时间组件的参数。


## 持续时间（秒），-1 表示无限。
@export var duration: float = -1