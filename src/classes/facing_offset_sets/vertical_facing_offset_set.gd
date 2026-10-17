@tool
extends FacingOffsetSet
class_name VerticalFacingOffsetSet
## 垂直双方向偏移组。
##
## 上、下每个 180 度表示一个偏移。


## 上方向的偏移。
@export var up := Vector2.ZERO:
	set(v):
		up = v
		emit_changed()
## 下方向的偏移。
@export var down := Vector2.ZERO:
	set(v):
		down = v
		emit_changed()
## 上下方向是否启用镜像。
@export var vertical_mirror: bool = false:
	set(v):
		vertical_mirror = v
		notify_property_list_changed()


func get_offset_toward_point(center: Vector2, point: Vector2) -> Vector2:
	var direction: Enums.Direction = MathUtils.get_quadrant_direction(center, point)
	var offset := Vector2.ZERO

	match direction:
		Enums.Direction.LEFT_UP, Enums.Direction.RIGHT_UP:
			offset = up
		Enums.Direction.LEFT_DOWN, Enums.Direction.RIGHT_DOWN:
			offset = down

	if vertical_mirror and direction & Enums.Direction.LEFT:
		offset *= Vector2(-1, 1)
	return offset


func to_dict() -> Dictionary[String, Vector2]:
	return {
		"up": up,
		"down": down,
	}
