extends Resource
class_name SyncAnimationsData
## 同步动画组资源。
##
## [SyncAnimationsData] 用于存储实体的同步动画数据，包括空闲、近战、远程战、行走、死亡、出生等动画。


@export var idle: FacingAnimationSet = null
@export var melee: FacingAnimationSet = null
@export var ranged: FacingAnimationSet = null
@export var walk: FacingAnimationSet = null
@export var death: FacingAnimationSet = null
@export var spawn: FacingAnimationSet = null
