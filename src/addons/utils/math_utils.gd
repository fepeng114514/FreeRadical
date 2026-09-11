@abstract
extends Object
class_name MathUtils


## 百分比转换为数字。
static func to_percent(number: float) -> float:
	return number / 100


## 判断点是否在圆中。
static func is_in_circle(center: Vector2, point: Vector2, radius: float) -> bool:
	var squared_distance: float = center.distance_squared_to(point)
	var squared_radius: float = radius ** 2

	return squared_distance <= squared_radius


## 判断点是否在圆环内。
static func is_in_ring(
		center: Vector2, point: Vector2, min_radius: float, max_radius: float
	) -> bool:
	var is_in_max_radius: bool = is_in_circle(center, point, max_radius)

	if min_radius <= 0:
		return is_in_max_radius

	return (
		is_in_max_radius
		and not is_in_circle(center, point, min_radius)
	)

	
## 根据点与圆的距离计算衰减。
static func get_radial_falloff(
		center: Vector2,
		point: Vector2,
		min_radius: float,
		max_radius: float,
		min_value: float = 0.0,
		max_value: float = 1.0
	) -> float:
	var value_difference: float = max_value - min_value
	var distance: float = center.distance_to(point)

	if min_radius == 0:
		return min_value + value_difference * (1 - distance / max_radius)
		
	var ring_dist: float = distance - min_radius
	var ring_radius: float = max_radius - min_radius
		
	return min_value + value_difference * (1 - ring_dist / ring_radius)
	
	
## 计算点在指定角度和半径上的另一点。[br][br]
## [param angle] 角度（弧度）。
static func get_point_on_circle(point: Vector2, radius: float, angle: float) -> Vector2:
	var direction: Vector2 = Vector2.from_angle(angle)
	var offset: Vector2 = direction * radius
		
	return point + offset


## 判断点是否位于椭圆中。
static func is_in_ellipse(
		center: Vector2, point: Vector2, radius: float, aspect: float = 0.7
	) -> bool:
	var major: float = radius
	var minor: float = radius * aspect
	var vector_difference: Vector2 = point - center

	var value: float = (vector_difference.x / major) ** 2 + (vector_difference.y / minor) ** 2
	return value <= 1


## 判断点是否位于椭圆环内。
static func is_in_ellipse_ring(
		center: Vector2, point: Vector2, min_radius: float, max_radius: float, aspect: float = 0.7
	) -> bool:
	var is_in_max_radius: bool = is_in_ellipse(center, point, max_radius, aspect)

	if min_radius <= 0:
		return is_in_max_radius

	return (
		is_in_max_radius
		and not is_in_ellipse(center, point, min_radius, aspect)
	)


## 根据点与椭圆的距离计算衰减。
static func get_ellipse_radial_falloff(
		center: Vector2,
		point: Vector2,
		max_radius: float,
		min_radius: float = 0.0,
		min_value: float = 0.0,
		max_value: float = 1.0,
		aspect: float = 0.7
	) -> float:
	var value_difference: float = max_value - min_value
	var angle: float = center.angle_to(point)
	var major: float = max_radius
	var minor: float = max_radius * aspect
	var local_point: Vector2 = point - center
	var local_point_len: float = local_point.length()
	var ellipse_point: Vector2 = Vector2(major * cos(angle), minor * sin(angle))
	var ellipse_len: float = ellipse_point.length()

	if min_radius == 0:
		return min_value + value_difference * (1 - local_point_len / ellipse_len)
		
	var min_major: float = min_radius
	var min_minor: float = min_radius * aspect
	var min_ellipse_point: Vector2 = Vector2(min_major * cos(angle), min_minor * sin(angle))
	var min_ellipse_len: float = min_ellipse_point.length()

	return min_value + value_difference * (1 - (local_point_len - min_ellipse_len) / (ellipse_len - min_ellipse_len))


## 计算点在指定角度和距离上椭圆空间的另一个点。[br][br]
## [param angle] 角度（弧度）。
static func get_point_on_ellipse(
		point: Vector2, radius: float, angle: float, aspect: float = 0.7
	) -> Vector2:
	var major: float = radius
	var minor: float = radius * aspect
	var x: float = point.x + major * cos(angle)
	var y: float = point.y + minor * sin(angle)

	return Vector2(x, y)


## 判断点是否位于扇形中。
static func is_in_sector(
		center: Vector2, point: Vector2, radius: float, angle_range: float, direction_angle: float
	) -> bool:
	if not is_in_circle(center, point, radius):
		return false

	var angle: float = center.angle_to(point)
	var angle_diff: float = abs(angle - direction_angle)

	return angle_diff <= angle_range / 2


## 判断点是否位于线段中。
static func is_in_line(
		center: Vector2, point: Vector2, width: float, length: float, angle: float = 0.0
	) -> bool:
	if is_in_circle(center, point, width):
		return true

	var local_point: Vector2 = point - center
	local_point = local_point.rotated(-angle)
	var local_point_x = local_point.x
	var local_point_y = local_point.y

	return (
		local_point_x <= length
		and local_point_x >= 0
		and local_point_y <= width
		and local_point_y >= -width
	)


## 根据距离与时间计算直线速度。
static func initial_linear_velocity(from: Vector2, to: Vector2, t: float) -> Vector2:
	var x: float = (to.x - from.x) / t
	var y: float = (to.y - from.y) / t

	return Vector2(x, y)


## 根据时间与速度计算位于直线上的位置。
static func position_in_linear(velocity: Vector2, from: Vector2, t: float) -> Vector2:
	var x: float = velocity.x * t + from.x
	var y: float = velocity.y * t + from.y

	return Vector2(x, y)
	
	
## 根据距离与时间计算抛物线速度。
static func initial_parabola_velocity(
		from: Vector2, to: Vector2, time: float, gravity: float
	) -> Vector2:
	var local_point: Vector2 = to - from
	var x: float = local_point.x / time
	var y: float = (local_point.y - gravity / 2 * time ** 2) / time

	return Vector2(x, y)
	
	
## 根据时间与速度计算位于抛物线上的位置。
static func get_position_in_parabola(
		velocity: Vector2, from: Vector2, time: float, gravity: float
	) -> Vector2:
	var local_x: float = velocity.x * time
	var local_y: float = gravity / 2 * time ** 2 + velocity.y * time

	return from + Vector2(local_x, local_y)


## 判断点是否到达目标位置。
static func is_at_destination(
		current_position: Vector2, target_position: Vector2, threshold: float = 5.0
	) -> bool:
	return current_position.distance_to(target_position) <= threshold


## 根据角度获取上/下/左/右四方向中的一个，见 [enum Constants.Direction]。
static func get_cardinal_direction(angle: float) -> Constants.Direction:
	var quarter_45: float = Constants.QUARTER_PI

	if angle >= -3 * quarter_45 and angle < -quarter_45:
		return Constants.Direction.UP

	if angle >= quarter_45 and angle < 3 * quarter_45:
		return Constants.Direction.DOWN

	if angle >= -quarter_45 and angle < quarter_45:
		return Constants.Direction.RIGHT

	return Constants.Direction.LEFT


## 根据目标点相对于中心点的位置获取象限方向，见 [enum Constants.Direction]。
static func get_quadrant_direction(center: Vector2, point: Vector2) -> Constants.Direction:
	var direction: int = Constants.Direction.NONE

	if point.y <= center.y:
		direction |= Constants.Direction.UP
	else:
		direction |= Constants.Direction.DOWN

	if point.x >= center.x:
		direction |= Constants.Direction.RIGHT
	else:
		direction |= Constants.Direction.LEFT

	return direction as Constants.Direction
