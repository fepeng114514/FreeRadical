@tool
extends Resource
class_name OffsetGroup
## 偏移数据资源
##
## 根据方向存储偏移


## 左方向的偏移
@export var left := Vector2.ZERO:
	set(value):
		left = value
		emit_changed()
## 左方向偏移是否作为右偏移的镜像
@export var mirror_horizontal: bool = false:
	set(value):
		mirror_horizontal = value
		notify_property_list_changed()
## 右方向的偏移
@export var right := Vector2.ZERO:
	set(value):
		right = value
		emit_changed()
## 上方向的偏移
@export var up := Vector2.ZERO:
	set(value):
		up = value
		emit_changed()
## 上方向偏移是否作为下偏移的镜像
@export var mirror_vertical: bool = false:
	set(value):
		mirror_vertical = value
		notify_property_list_changed()
## 下方向的偏移
@export var down := Vector2.ZERO:
	set(value):
		down = value
		emit_changed()
## 任意方向的偏移
@export var any := Vector2.ZERO:
	set(value):
		any = value
		emit_changed()


func _validate_property(property: Dictionary):
	match property.name:
		"left":
			if mirror_horizontal:
				property.usage = PROPERTY_USAGE_NONE
		"up":
			if mirror_vertical:
				property.usage = PROPERTY_USAGE_NONE

## 根据方向获取相应偏移
func get_offset_for_point(center: Vector2, point: Vector2) -> Vector2:
	if any:
		return any

	var angle: float = center.angle_to_point(
		point
	)
	var has_horizontal: bool = left or right
	var has_vertical: bool = up or down
	var direction: C.Direction = U.get_direction_by_angle(angle, has_horizontal, has_vertical)

	match direction:
		C.Direction.UP:
			if mirror_vertical:
				return down * Vector2(-1, 1)
			else:
				return up
		C.Direction.DOWN:
			return down
		C.Direction.LEFT:
			if mirror_horizontal:
				return right * Vector2(-1, 1)
			else:
				return left
		C.Direction.RIGHT:
			return right
				
	return Vector2.ZERO


## 序列化为字典
func to_dict() -> Dictionary[String, Vector2]:
	return {
		"left": left,
		"right": right,
		"up": up,
		"down": down,
		"any": any,
	}
