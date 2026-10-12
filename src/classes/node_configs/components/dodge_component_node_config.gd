@tool
extends NodeConfig
class_name DodgeComponentNodeConfig
## 闪避组件节点配置资源。
##
## [DodgeComponentNodeConfig] 用于存储 [DodgeComponent] 的可配置数据。


## 是否可以闪避远程攻击。
@export var can_dodge_ranged: bool = true
## 是否可以闪避近战技能。
@export var can_dodge_melee: bool = true
## 是否可以闪避区域攻击。
@export var can_dodge_area: bool = false
