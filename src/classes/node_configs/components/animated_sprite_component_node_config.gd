@tool
extends NodeConfig
class_name AnimatedSpriteComponentNodeConfig
## 动画精灵组件节点配置。
##
## [AnimatedSpriteComponentNodeConfig] 用于存储 [AnimatedSpriteComponent] 的可配置数据。


## 空闲动画组。
@export var idle_animation: AnimationGroup = null

@export_group("Sync Animation")
## 是否所有者同步播放动画。
@export var sync_source: bool = false
## 同步动画组数据。
@export var sync_animations: SyncAnimationsData = null
