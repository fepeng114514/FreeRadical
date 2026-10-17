@tool
extends NodeConfig
class_name NavPathComponentNodeConfig
## 导航路径组件节点配置资源。
##
## [NavPathComponentNodeConfig] 用于存储 [NavPathComponent] 的可配置数据。


## 是否沿相反路线移动。
@export var reversed_enabled: bool = false
## 移动速度。
@export var speed: float = 133.0
## 移动动画组。
@export var motion_animation: FacingAnimationSet = null
## 是否强制与来源实体所在路径同步。
@export var sync_source_path: bool = true

@export_group("End")
## 终点节点。
@export var end_pathway_node_index: int = Constants.UNSET
## 是否启用循环。
@export var loop_enabled: bool = false
## 循环次数，循环指定次数后再到达终点节点将会到达终点。
@export var loop_times: int = Constants.UNSET
## 到达终点消耗的生命。
@export var life_cost: int = 1
