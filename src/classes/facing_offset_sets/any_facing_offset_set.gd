@tool
extends FacingOffsetSet
class_name AnyFacingOffsetSet
## 任意方向偏移组。
##
## 任意方向使用同一个偏移。


## 任意方向的偏移。
@export var any := Vector2.ZERO:
	set(v):
		any = v
		emit_changed()


func get_offset_toward_point(_center: Vector2, _point: Vector2) -> Vector2:
	return any


func to_dict() -> Dictionary[String, Vector2]:
	return {
		"any": any,
	}
