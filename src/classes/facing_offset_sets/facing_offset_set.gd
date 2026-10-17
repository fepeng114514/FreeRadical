@abstract
@tool
extends Resource
class_name FacingOffsetSet
## 朝向偏移组基类。
##
## [FacingOffsetSet] 是所有朝向偏移的基类，用于根据实体看向的方向获取偏移。


## 根据中心点到目标点的方向返回对应的偏移。
@abstract
func get_offset_toward_point(center: Vector2, point: Vector2) -> Vector2


## 序列化为字典。
@abstract
func to_dict() -> Dictionary[String, Vector2]


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
