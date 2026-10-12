@tool
extends NodeConfig
class_name SpriteComponentNodeConfig
## 精灵组件节点配置资源。
##
## [SpriteComponentNodeConfig] 用于存储 [SpriteComponent] 的可配置数据。


@export_group("Sync Animation")
## 是否所有者同步播放动画。
@export var sync_source: bool = false
## 同步动画组数据。
@export var sync_animations: SyncAnimationsData = null
