@abstract
@tool
extends Resource
class_name FacingAnimationSet
## 朝向动画组基类。
##
## [FacingAnimationSet] 是所有朝向动画组的基类，用于根据实体看向的方向获取动画名称。


## 要播放的精灵/精灵组索引。
@export var play_index: int = 0
## 播放次数。
@export var times: int = 1
## 播放倍速。
@export var speed_scale: float = 1.0


func _init():
	resource_local_to_scene = true


## 根据中心点到目标点的方向返回对应的动画名称。
@abstract
func get_animation_name_toward_point(_center: Vector2, _point: Vector2) -> AnimationData
