@tool
extends Resource
class_name OffsetGroup
## 偏移组资源。
##
## OffsetGroup 根据方向存储偏移，用于根据实体看向的方向获取偏移。


## 左方向的偏移。
@export var left := Vector2.ZERO:
	set(v): 
		left = v
		emit_changed()
## 左方向偏移是否作为右偏移的镜像。
@export var mirror_horizontal: bool = false:
	set(v): 
		mirror_horizontal = v
		notify_property_list_changed()
## 右方向的偏移。
@export var right := Vector2.ZERO:
	set(v): 
		right = v
		emit_changed()
## 上方向的偏移。
@export var up := Vector2.ZERO:
	set(v): 
		up = v
		emit_changed()
## 上方向偏移是否作为下偏移的镜像。
@export var mirror_vertical: bool = false:
	set(v): 
		mirror_vertical = v
		notify_property_list_changed()
## 下方向的偏移。
@export var down := Vector2.ZERO:
	set(v): 
		down = v
		emit_changed()
## 任意方向的偏移。
@export var any := Vector2.ZERO:
	set(v): 
		any = v
		emit_changed()


func _validate_property(property: Dictionary):
	match property.name:
		"left":
			if mirror_horizontal:
				property.usage = PROPERTY_USAGE_NONE
		"up":
			if mirror_vertical:
				property.usage = PROPERTY_USAGE_NONE
				

## 根据方向获取相应偏移。
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


## 绘制偏移组。
static func draw_offset_group(
		drawer: CanvasItem, offset_group: OffsetGroup ,radius: float = 3, color := Color.GREEN
	) -> void:
	if not offset_group:
		return

	var cross_len: float = radius * 1.5
	for offset_value: Vector2 in offset_group.to_dict().values():
		if offset_value == Vector2.ZERO:
			continue

		# 中间的圆
		var fill_color: Color = Color(color.r, color.g, color.b, 0.4)
		drawer.draw_circle(offset_value, radius * 0.8, fill_color, true)
		drawer.draw_circle(offset_value, radius, color, false, 1.2)

		# 十字线
		var p1: Vector2 = offset_value + Vector2(-cross_len, 0)
		var p2: Vector2 = offset_value + Vector2(cross_len, 0)
		var p3: Vector2 = offset_value + Vector2(0, -cross_len)
		var p4: Vector2 = offset_value + Vector2(0, cross_len)
		drawer.draw_line(p1, p2, color, 1.2)
		drawer.draw_line(p3, p4, color, 1.2)
