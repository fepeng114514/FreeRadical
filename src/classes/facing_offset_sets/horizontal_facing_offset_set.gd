@tool
extends FacingOffsetSet
class_name HorizontalFacingOffsetSet
## 水平双方向偏移组。
##
## 左、右每个 180 度表示一个偏移。


## 左方向的偏移。
@export var left := Vector2.ZERO:
	set(v):
		left = v
		emit_changed()
## 右方向偏移是否启用镜像替换左方向偏移。
@export var right_replace_left: bool = false:
	set(v):
		right_replace_left = v
		notify_property_list_changed()
## 右方向的偏移。
@export var right := Vector2.ZERO:
	set(v):
		right = v
		emit_changed()


func _validate_property(property: Dictionary):
	if property.name == "left" and right_replace_left:
		property.usage = PROPERTY_USAGE_NONE


func get_offset_toward_point(center: Vector2, point: Vector2) -> Vector2:
	var direction: Enums.Direction = MathUtils.get_quadrant_direction(center, point)

	match direction:
		Enums.Direction.LEFT_UP, Enums.Direction.LEFT_DOWN:
			if right_replace_left:
				return right * Vector2(-1, 1)
			else:
				return left
		Enums.Direction.RIGHT_UP, Enums.Direction.RIGHT_DOWN:
			return right
	return Vector2.ZERO


func to_dict() -> Dictionary[String, Vector2]:
	return {
		"left": left,
		"right": right,
	}
