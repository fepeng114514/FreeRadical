@tool
extends NodeConfig
class_name RallyComponentNodeConfig
## 集结组件节点配置资源。


## 移动速度。
@export var speed: float = 100.0
## 是否可点击集结。
@export var can_select_rally: bool = true
## 移动动画组。
@export var motion_animation: AnimationGroup = null
## 移动音效组。
@export var motion_sfx: AudioGroup = null
