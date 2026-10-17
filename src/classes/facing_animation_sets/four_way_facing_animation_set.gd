@tool
extends FacingAnimationSet
class_name FourWayFacingAnimationSet
## 四方向动画组。
##
## 上、下、左、右每个 90 度表示一个动画名称。


## 左方向的动画名。
@export var left: StringName = &""
## 右方向的动画名。
@export var right: StringName = &""
## 右方向的动画是否以镜像方式替换左方向的动画。
@export var right_replace_left: bool = false:
	set(v):
		right_replace_left = v
		notify_property_list_changed()
## 上方向的动画名。
@export var up: StringName = &""
## 下方向的动画名。
@export var down: StringName = &""


func _validate_property(property: Dictionary):
	if property.name == "left" and right_replace_left:
		property.usage = PROPERTY_USAGE_NONE


func get_animation_name_toward_point(center: Vector2, point: Vector2) -> AnimationData:
	var anim_data := AnimationData.new()
	var angle: float = center.angle_to_point(point)
	var direction: Enums.Direction = MathUtils.get_cardinal_direction(angle)

	match direction:
		Enums.Direction.UP:
			anim_data.anim_name = up
		Enums.Direction.DOWN:
			anim_data.anim_name = down
		Enums.Direction.LEFT:
			if right_replace_left:
				anim_data.anim_name = right
				anim_data.flip_h = true
			else:
				anim_data.anim_name = left
		Enums.Direction.RIGHT:
			anim_data.anim_name = right
	anim_data.direction = direction

	return anim_data
