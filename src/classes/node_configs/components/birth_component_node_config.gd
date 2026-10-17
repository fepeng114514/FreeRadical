@tool
extends NodeConfig
class_name BirthComponentNodeConfig
## 出生组件节点配置。
##
## [BirthComponentNodeConfig] 用于存储 [BirthComponent] 的可配置数据。


## 出生时播放的动画。
@export var birth_animation: FacingAnimationSet = null
## 出生时播放的音效组。
@export var birth_sfx: AudioGroup = null
