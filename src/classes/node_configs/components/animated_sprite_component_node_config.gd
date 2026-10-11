@tool
extends NodeConfig
class_name AnimatedSpriteComponentNodeConfig


## 空闲动画组
@export var idle_animation: AnimationGroup = null
## 生成时播放的动画
@export var spawn_animation: AnimationGroup = null
## 生成时播放的音效组。
@export var spawn_sfx: AudioGroup = null

@export_group("Sync Animation")
## 是否所有者同步播放动画。
@export var sync_source: bool = false
## 同步动画组数据。
@export var sync_animations: SyncAnimationsData = null
