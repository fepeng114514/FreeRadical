@tool
extends Resource
class_name OffsetGroup
## 偏移组资源。
##
## OffsetGroup 根据方向存储偏移，用于根据实体看向的方向获取偏移。[br][br]
## 根据填写的属性会动态生成三种偏移组：[br]
## 1. 双方向偏移组：填写 [member left]、[member right] 或 [member up]、[member down]，每个 180 度表示一个偏移。[br]
## 2. 四方向偏移组：填写所有方向的偏移 [member left]、[member right]、[member up]、[member down]，每个 90 度表示一个偏移。[br]


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
## 上方向的偏移。
@export var up := Vector2.ZERO:
	set(v): 
		up = v
		emit_changed()
## 下方向偏移是否以镜像方式替换上方向偏移。
@export var down_replace_up: bool = false:
	set(v): 
		down_replace_up = v
		notify_property_list_changed()
## 下方向的偏移。
@export var down := Vector2.ZERO:
	set(v): 
		down = v
		emit_changed()
## 上下方向是否启用镜像，仅用于双方向偏移组。
@export var vertical_mirror: bool = false:
	set(v): 
		vertical_mirror = v
		notify_property_list_changed()

## 任意方向的偏移。
@export var any := Vector2.ZERO:
	set(v): 
		any = v
		emit_changed()


func _validate_property(property: Dictionary):
	match property.name:
		"left":
			if right_replace_left:
				property.usage = PROPERTY_USAGE_NONE
		"up":
			if down_replace_up:
				property.usage = PROPERTY_USAGE_NONE
				

## 根据方向获取相应偏移。
func get_offset_for_point(center: Vector2, point: Vector2) -> Vector2:
	if any:
		return any

	var has_horizontal: bool = left or right
	var has_vertical: bool = up or down
	var direction: C.Direction = C.Direction.NONE
	var offset := Vector2.ZERO

	if has_horizontal and has_vertical:
		var angle: float = center.angle_to_point(
			point
		)
		direction = U.get_cardinal_direction(angle)
		match direction:
			C.Direction.UP:
				if down_replace_up:
					offset = down * Vector2(-1, 1)
				else:
					offset = up
			C.Direction.DOWN:
				offset = down
			C.Direction.LEFT:
				if right_replace_left:
					offset = right * Vector2(-1, 1)
				else:
					offset = left
			C.Direction.RIGHT:
				offset = right
	elif has_horizontal or has_vertical:
		direction = U.get_quadrant_direction(center, point)
		if has_horizontal:
			match direction:
				C.Direction.LEFT_UP, C.Direction.LEFT_DOWN:
					if right_replace_left:
						offset = right * Vector2(-1, 1)
					else:
						offset = left
				C.Direction.RIGHT_UP, C.Direction.RIGHT_DOWN:
					offset = right
		elif has_vertical:
			match direction:
				C.Direction.LEFT_UP, C.Direction.RIGHT_UP:
					if down_replace_up:
						offset = down * Vector2(-1, 1)
					else:
						offset = up
				C.Direction.LEFT_DOWN, C.Direction.RIGHT_DOWN:
					offset = down
			
			if vertical_mirror and direction & C.Direction.LEFT:
				offset *= Vector2(-1, 1)
	return offset


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
		if not offset_value:
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
