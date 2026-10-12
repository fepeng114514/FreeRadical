extends Resource
class_name SyncAnimationsData
## 同步动画组资源。
##
## [SyncAnimationsData] 用于存储实体的同步动画数据，包括空闲、近战、远程战、行走、死亡、出生等动画。


@export var idle: AnimationGroup = null
@export var melee: AnimationGroup = null
@export var ranged: AnimationGroup = null
@export var walk: AnimationGroup = null
@export var death: AnimationGroup = null
@export var spawn: AnimationGroup = null
