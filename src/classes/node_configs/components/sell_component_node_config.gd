@tool
extends NodeConfig
class_name SellComponentNodeConfig
## 出售组件节点配置资源。


## 出售比例（%）
@export var sell_ratio: float = 0.5
## 出售音效组。
@export var sell_sfx: AudioGroup = null
## 是否启用出售。
@export var sell_enabled: bool = true