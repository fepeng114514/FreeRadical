@tool
extends Resource
class_name OffsetGroup
## 偏移组资源。
##
## [OffsetGroup] 根据方向存储偏移，用于根据实体看向的方向获取偏移。[br][br]
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
				

## 根据中心点到目标点的方向返回对应的偏移。
func get_offset_toward_point(center: Vector2, point: Vector2) -> Vector2:
	if any:
		return any

	var has_horizontal: bool = left or right
	var has_vertical: bool = up or down
	var direction: Enums.Direction = Enums.Direction.NONE
	var offset := Vector2.ZERO

	if has_horizontal and has_vertical:
		var angle: float = center.angle_to_point(
			point
		)
		direction = MathUtils.get_cardinal_direction(angle)
		match direction:
			Enums.Direction.UP:
				offset = up
			Enums.Direction.DOWN:
				offset = down
			Enums.Direction.LEFT:
				if right_replace_left:
					offset = right * Vector2(-1, 1)
				else:
					offset = left
			Enums.Direction.RIGHT:
				offset = right
	elif has_horizontal:
		direction = MathUtils.get_quadrant_direction(center, point)
		match direction:
			Enums.Direction.LEFT_UP, Enums.Direction.LEFT_DOWN:
				if right_replace_left:
					offset = right * Vector2(-1, 1)
				else:
					offset = left
			Enums.Direction.RIGHT_UP, Enums.Direction.RIGHT_DOWN:
				offset = right
	elif has_vertical:
		direction = MathUtils.get_quadrant_direction(center, point)
		match direction:
			Enums.Direction.LEFT_UP, Enums.Direction.RIGHT_UP:
				offset = up
			Enums.Direction.LEFT_DOWN, Enums.Direction.RIGHT_DOWN:
				offset = down
		
		if vertical_mirror and direction & Enums.Direction.LEFT:
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
func draw_offset_group(
		drawer: CanvasItem, radius: float = 3, color := Color.GREEN
	) -> void:
	var cross_len: float = radius * 1.5
	for offset_value: Vector2 in to_dict().values():
		if not offset_value:
			continue

		var fill_color: Color = Color(color.r, color.g, color.b, 0.4)
		drawer.draw_circle(offset_value, radius * 0.8, fill_color, true)
		drawer.draw_circle(offset_value, radius, color, false, 1.2)

		var p1: Vector2 = offset_value + Vector2(-cross_len, 0)
		var p2: Vector2 = offset_value + Vector2(cross_len, 0)
		var p3: Vector2 = offset_value + Vector2(0, -cross_len)
		var p4: Vector2 = offset_value + Vector2(0, cross_len)
		drawer.draw_line(p1, p2, color, 1.2)
		drawer.draw_line(p3, p4, color, 1.2)
