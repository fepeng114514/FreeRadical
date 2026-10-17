@tool
extends FacingAnimationSet
class_name AnyFacingAnimationSet
## 任意方向动画组。
##
## 任意方向使用同一个动画名称。


## 任意方向的动画名。
@export var any: StringName = &""


func get_animation_name_toward_point(_center: Vector2, _point: Vector2) -> AnimationData:
	var anim_data := AnimationData.new()
	anim_data.anim_name = any
	return anim_data
