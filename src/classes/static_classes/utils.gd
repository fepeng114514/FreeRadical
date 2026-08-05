class_name U
## 工具函数库。


#region 数学工具函数
## 秒转换为帧时间。
static func fts(time: float) -> float:
	return time / C.FPS


## 百分比转换为数字。
static func to_percent(num: float) -> float:
	return num / 100


## 检查是否是有效数字。
static func is_valid_number(n: float) -> bool:
	return n != C.UNSET


## 判断点是否在圆中。
static func is_in_circle(center: Vector2, point: Vector2, radius: float) -> bool:
	var d_sq: float = center.distance_squared_to(point)
	var r_sq: float = radius ** 2
	
	return d_sq <= r_sq
	
	
## 计算根据点与圆的距离计算衰减。
static func get_radial_falloff(
		center: Vector2, 
		point: Vector2, 
		min_radius: float, 
		max_radius: float, 
		min_value: float = 0.0,
		max_value: float = 1.0
	) -> float:
	var dv: float = max_value - min_value
	var dist: float = center.distance_to(point)
	
	if min_radius == 0:
		return min_value + dv * (1 - dist / max_radius)
		
	var ring_dist: float = dist - min_radius
	var ring_radius: float = max_radius - min_radius
		
	return min_value + dv * (1 - ring_dist / ring_radius)
	
	
## 计算点在指定角度和半径上的另一点。[br][br]
## [param angle] 角度（弧度）。
static func get_point_on_circle(point: Vector2, radius: float, angle: float) -> Vector2:
	var dir: Vector2 = Vector2.from_angle(angle)
	var d: Vector2 = dir * radius
		
	return point + d


## 判断点是否在圆环内。
static func is_in_ring(
		center: Vector2, point: Vector2, min_radius: float, max_radius: float
	) -> bool:
	var is_in_max_radius: bool = U.is_in_circle(center, point, max_radius)

	if min_radius <= 0:
		return is_in_max_radius

	return (
		is_in_max_radius
		and not U.is_in_circle(center, point, min_radius)
	)


## 判断点是否位于椭圆中。
static func is_in_ellipse(
		center: Vector2, point: Vector2, radius: float, aspect: float = 0.7
	) -> bool:
	var a: float = radius
	var b: float = radius * aspect
	var dx: float = point.x - center.x
	var dy: float = point.y - center.y
	
	var value: float = (dx / a) ** 2 + (dy / b) ** 2
	
	return value <= 1


## 判断点是否位于椭圆环内。
static func is_in_ellipse_ring(
		center: Vector2, point: Vector2, min_radius: float, max_radius: float, aspect: float = 0.7
	) -> bool:
	var is_in_max_radius: bool = U.is_in_ellipse(center, point, max_radius, aspect)

	if min_radius <= 0:
		return is_in_max_radius

	return (
		is_in_max_radius
		and not U.is_in_ellipse(center, point, min_radius, aspect)
	)


## 计算根据点与椭圆的距离衰减的因子。
static func get_ellipse_radial_falloff(	
		center: Vector2, 
		point: Vector2, 
		max_radius: float, 
		min_radius: float = 0.0, 
		aspect: float = 0.7
	) -> float:
	var angle: float = center.angle_to(point)
	var a: float = max_radius
	var b: float = max_radius * aspect
	var v_len: float = Vector2(point.x - center.x, point.y - center.y).length()
	var e_len: float = Vector2(a * cos(angle), b * sin(angle)).length()

	if min_radius == 0:
		return v_len / e_len
		
	var ma: float = min_radius
	var mb: float = min_radius * aspect
	var me_len: float = Vector2(ma * cos(angle), mb * sin(angle)).length()

	return (v_len - me_len) / (e_len - me_len)


## 计算点在指定角度和距离上椭圆空间的另一个点。[br][br]
## [param angle] 角度（弧度）。
static func get_point_on_ellipse(
		point: Vector2, radius: float, angle: float, aspect: float = 0.7
	) -> Vector2:
	var a: float = radius
	var b: float = radius * aspect
	var x: float = point.x + a * cos(angle)
	var y: float = point.y + b * sin(angle)

	return Vector2(x, y)


## 判断点是否位于扇形中。
static func is_in_sector(
		center: Vector2, point: Vector2, radius: float, angle_range: float, direction_angle: float
	) -> bool:
	if not is_in_circle(center, point, radius):
		return false
	
	var angle_to_point: float = center.angle_to(point)
	var delta_angle: float = abs(angle_to_point - direction_angle)
	
	return delta_angle <= angle_range / 2


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
		from: Vector2, to: Vector2, t: float, g: float
	) -> Vector2:
	var dv: Vector2 = to - from
	var x: float = dv.x / t
	var y: float = (dv.y - g * t * t / 2) / t
	
	return Vector2(x, y)
	
	
## 根据时间与速度计算位于抛物线上的位置。
static func get_position_in_parabola(
		velocity: Vector2, from: Vector2, t: float, g: float
	) -> Vector2:
	var x: float = velocity.x * t + from.x
	var y: float = g * t * t / 2 + velocity.y * t + from.y

	return Vector2(x, y)


## 判断点是否到达目标位置。
static func is_at_destination(
		current_pos: Vector2, target_pos: Vector2, threshold: float = 5.0
	) -> bool:
	return current_pos.distance_to(target_pos) <= threshold


## 根据角度获取上/下/左/右四方向中的一个，见 [enum C.Direction]。
static func get_cardinal_direction(angle: float) -> C.Direction:
	var quarter_45: float = C.QUARTER_PI

	if angle >= -3 * quarter_45 and angle < -quarter_45:
		return C.Direction.UP
	
	if angle >= quarter_45 and angle < 3 * quarter_45:
		return C.Direction.DOWN
	
	if angle >= -quarter_45 and angle < quarter_45:
		return C.Direction.RIGHT

	return C.Direction.LEFT


## 根据目标点相对于中心点的位置获取象限方向，见 [enum C.Direction]。
static func get_quadrant_direction(center: Vector2, point: Vector2) -> C.Direction:
	var direction: int = C.Direction.NONE

	if point.y <= center.y:
		direction |= C.Direction.UP
	else:
		direction |= C.Direction.DOWN
	
	if point.x >= center.x:
		direction |= C.Direction.RIGHT
	else:
		direction |= C.Direction.LEFT

	return direction as C.Direction
#endregion


#region 路径工具函数
## 打开目录。
static func open_directory(path: String) -> DirAccess:
	var dir: DirAccess = DirAccess.open(path)
	if not dir:
		Log.error(
			"list_directory_simple: 无法打开目录: %s\n错误信息: %s" % [
				path, DirAccess.get_open_error()
			]
		)

	return dir


## 递归获取目录下所有文件。
static func get_files_from_nested_directory(dir_path: String, match_pattern: String = "") -> PackedStringArray:	
	var file_path_list := PackedStringArray()
	var dir: DirAccess = open_directory(dir_path)

	dir.list_dir_begin()
	var item: String = dir.get_next()
	while item != "":
		var item_path: String = dir_path.path_join(item)

		if dir.dir_exists(item_path):
			file_path_list.append_array(get_files_from_nested_directory(item_path, match_pattern))
		elif dir.file_exists(item_path) and item_path.match(match_pattern):
			file_path_list.append(item_path)

		item = dir.get_next()
	dir.list_dir_end()

	return file_path_list
#endregion


#region JSON 工具函数
## 加载 JSON 文件。
static func load_json(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		Log.error("load_json: JSON 文件不存在: %s" % path)
		return null
	
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if not file:
		Log.error("load_json: 无法打开文件: %s" % path)
		return null
	
	var content: String = file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var parse_result: int = json.parse(content)
	
	if parse_result != OK:
		Log.error(
			"load_json: JSON 解析错误: %s\n错误行: %d" % [
				json.get_error_message(), json.get_error_line()
			]
		)
		return null
	
	return json.get_data()
	
	
## 保存 JSON 文件。
static func save_json(data: Variant, file_path: String) -> void:
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		Log.error("save_json: 无法打开文件: %s\n错误信息: %s" % [
				file_path, FileAccess.get_open_error()
			]
		)
		return
		
	var json_string: String = JSON.stringify(data, "\t")
	file.store_string(json_string)
	file.close()
	Log.info("save_json: 保存成功: %s" % file_path)
#endregion


#region 深拷贝工具函数
## 浅拷贝，不同于 duplicate 此方法会安全处理不同类型的数据。
static func clone(value: Variant) -> Variant:
	if value is Dictionary:
		var result: Dictionary = {}
		for key in value:
			result[key] = value[key]
		return result
	
	if value is Array:
		var result: Array = []
		for item in value:
			result.append(item)
		return result
	
	# 基础类型和不可变对象直接返回
	return value
	
	
## 深拷贝，不同于 duplicate_deep 此方法会安全处理不同类型的数据。
static func deepclone(value: Variant) -> Variant:
	# 对于字典，递归复制
	if value is Dictionary:
		var result: Dictionary = {}
		for key in value:
			result[key] = deepclone(value[key])
		return result
	
	# 对于数组，同样递归复制
	if value is Array:
		var result: Array = []
		for item in value:
			result.append(deepclone(item))
		return result
	
	# 尝试调用对象的 duplicate 方法
	if value is Object and value.has_method("duplicate"):
		return value.duplicate()
	
	# 基础类型和不可变对象直接返回
	return value


## 深合并字典。
static func deepmerge_dict(
		target: Dictionary, source: Dictionary, overwrite: bool = true
	) -> void:
	for key in source:
		var source_value: Variant = deepclone(source[key])
		
		# 如果 target 没有这个键，直接赋值
		if not target.has(key):
			target[key] = source_value
			continue
		
		if not overwrite:
			continue
		
		# 其他类型：source 覆盖 target
		target[key] = source_value
		
		
## 创建新字典并深合并字典。
static func deepmerge_dict_new(
		target: Dictionary, source: Dictionary, overwrite: bool = true
	) -> Dictionary:
	var result: Dictionary = deepclone(target)
	deepmerge_dict(result, source, overwrite)
	return result


## 浅合并数组。
static func merge_array(
		target: Array, source: Array, overwrite: bool = true
	) -> void:
	var target_size: int = target.size()
	for i in source.size():
		var mv: Variant = source[i]
		
		if i >= target_size:
			target.append(mv)
			continue
		
		if not overwrite:
			continue
		
		target[i] = mv
	
	
## 创建新数组并浅合并数组。
static func merge_array_new(
		target: Array, source: Array, overwrite: bool = true
	) -> Array:
	var result: Array = deepclone(target)
	merge_array(result, source, overwrite)
	return result
		
		
## 深合并数组。
static func deepmerge_array(
		target: Array, source: Array, overwrite: bool = true
	) -> void:
	var target_size: int = target.size()
	for i in source.size():
		var mv: Variant = deepclone(source[i])
		
		if i >= target_size:
			target.append(mv)
			continue
		
		if not overwrite:
			continue
		
		target[i] = mv


## 创建新数组并深合并数组。
static func deepmerge_array_new(
		target: Array, source: Array, overwrite: bool = true
	) -> Array:
	var result: Array = deepclone(target)
	deepmerge_array(result, source, overwrite)
	return result
	
	
## 递归浅合并字典。
static func merge_dict_recursive(
		target: Dictionary, source: Dictionary, overwrite: bool = true
	) -> void:
	for key in source:
		var source_value: Variant = source[key]
		
		# 如果 target 没有这个键，直接赋值
		if not target.has(key):
			target[key] = source_value
			continue
			
		var target_value: Variant = target[key]
		
		# 字典合并字典
		if target_value is Dictionary and source_value is Dictionary:
			merge_dict_recursive(target_value, source_value, overwrite)
			continue
		
		# 数组合并数组
		if target_value is Array and source_value is Array:
			merge_array_recursive(target_value, source_value, overwrite)
			continue
			
		if not overwrite:
			continue
		
		# 其他类型：source 覆盖 target
		target[key] = source_value
		
		
## 创建新字典并递归浅合并两个字典。
static func merge_dict_recursive_new(
		target: Dictionary, source: Dictionary, overwrite: bool = true
	) -> Dictionary:
	var result: Dictionary = deepclone(target)
	merge_dict_recursive(result, source, overwrite)
	return result


## 递归深合并字典。
static func deepmerge_dict_recursive(
		target: Dictionary, source: Dictionary, overwrite: bool = true
	) -> void:
	for key in source:
		var source_value: Variant = deepclone(source[key])
		
		# 如果 target 没有这个键，直接赋值
		if not target.has(key):
			target[key] = source_value
			continue
			
		var target_value: Variant = target[key]
		
		# 字典合并字典
		if target_value is Dictionary and source_value is Dictionary:
			deepmerge_dict_recursive(target_value, source_value, overwrite)
			continue
		
		# 数组合并数组
		if target_value is Array and source_value is Array:
			deepmerge_array_recursive(target_value, source_value, overwrite)
			continue
			
		if not overwrite:
			continue
		
		# 其他类型：source 覆盖 target
		target[key] = source_value
		
		
## 创建新字典并递归深合并两个字典。
static func deepmerge_dict_recursive_new(
		target: Dictionary, source: Dictionary, overwrite: bool = true
	) -> Dictionary:
	var result: Dictionary = deepclone(target)
	deepmerge_dict_recursive(result, source, overwrite)
	return result


## 递归浅合并数组。
static func merge_array_recursive(
		target: Array, source: Array, overwrite: bool = true
	) -> void:
	for i in source.size():
		var source_value: Variant = source[i]
		
		# 如果 target 没有这个索引，直接追加
		if i >= target.size():
			target.append(source_value)
			continue
			
		var target_value: Variant = target[i]
		
		# 字典合并字典
		if target_value is Dictionary and source_value is Dictionary:
			merge_dict_recursive(target_value, source_value, overwrite)
			continue
		
		# 数组合并数组
		if target_value is Array and source_value is Array:
			merge_array_recursive(target_value, source_value, overwrite)
			continue
			
		if not overwrite:
			continue
		
		# 其他类型：source 覆盖 target
		target[i] = source_value


## 创建新数组并递归浅合并两个数组。
static func merge_array_recursive_new(
		target: Array, source: Array, overwrite: bool = true
	) -> Array:
	var result: Array = deepclone(target)
	merge_array_recursive(result, source, overwrite)
	return result
	
	
## 递归深合并数组。
static func deepmerge_array_recursive(
		target: Array, source: Array, overwrite: bool = true
	) -> void:
	for i in source.size():
		var source_value: Variant = deepclone(source[i])
		
		# 如果 target 没有这个索引，直接追加
		if i >= target.size():
			target.append(source_value)
			continue
			
		var target_value: Variant = target[i]
		
		# 字典合并字典
		if target_value is Dictionary and source_value is Dictionary:
			deepmerge_dict_recursive(target_value, source_value, overwrite)
			continue
		
		# 数组合并数组
		if target_value is Array and source_value is Array:
			deepmerge_array_recursive(target_value, source_value, overwrite)
			continue
			
		if not overwrite:
			continue
		
		# 其他类型：source 覆盖 target
		target[i] = source_value


## 创建新数组并递归深合并两个数组。
static func deepmerge_array_recursive_new(
		target: Array, source: Array, overwrite: bool = true
	) -> Array:
	var result: Array = deepclone(target)
	deepmerge_array_recursive(result, source, overwrite)
	return result
#endregion


## 从节点名称中提取组件名称
static func get_component_name(node_name: String) -> String:
	return node_name.replace("Component", "")


## 判断实体是否有效。
static func is_valid_entity(e) -> bool:
	return (
		e
		and not e.state & Entity.State.REMOVED 
	)


#region 位运算相关方法
## 判断标识掩码是否被禁止掩码禁止。
static func is_banned(flags: int, bans: int) -> bool:
	return flags & bans


## 判断标识掩码是否双向被禁止掩码禁止。
static func is_mutual_banned(flags1: int, bans1: int, flags2: int, bans2: int) -> bool:
	return is_banned(flags1, bans1) or is_banned(flags2, bans2)


## 合并多个标志位。
static func merge_flags(flag_list: Array) -> int:
	var new_flags: int = 0
	
	for flag: int in flag_list:
		new_flags |= flag
		
	return new_flags
#endregion


#region 数组相关方法
## 从数组中随机选择一个元素，仅用于从紧缩数组中随机选择一个元素。
static func pick_random(array: Array) -> Variant:
	if array.is_empty():
		return null
		
	return array[randi() % array.size()]
#endregion


#region 绘制相关方法
## 绘制范围圆，包含最小范围和最大范围的填充圆。[br][br]
## [param position] 为局部空间位置。[br]
## [param width] 为轮廓的宽度。
static func draw_range_circle(
		drawer: CanvasItem, 
		position: Vector2, 
		min_range: float, 
		max_range: float, 
		color := Color(0, 1, 0, 0.2),
		width: float = 3
	) -> void:
	var range_list := PackedFloat32Array([
		min_range,
		max_range
	])

	for radius: float in range_list:
		# 绘制轮廓
		drawer.draw_circle(
			position, 
			radius,
			color, 
			false,
			width
		)
		# 绘制填充圆
		drawer.draw_circle(
			position, 
			radius,
			color, 
		)


## 绘制范围椭圆，包含最小范围和最大范围的填充椭圆。[br][br]
## [param position] 为局部空间位置。[br]
## [param color] 为椭圆轮廓与填充的颜色。[br]
## [param width] 为椭圆轮廓的宽度。
static func draw_range_ellipse(
		drawer: CanvasItem, 
		position: Vector2, 
		min_range: float, 
		max_range: float, 
		color := Color(0, 1, 0, 0.2),
		width: float = 3,
		aspect: float = 0.7
	) -> void:
	var range_list := PackedFloat32Array([
		min_range,
		max_range
	])
	
	for radius: float in range_list:
		var minor: float = radius * aspect
		# 绘制轮廓
		drawer.draw_ellipse(
			position, 
			radius,
			minor, 
			color,
			false,
			width
		)
		# 绘制填充椭圆
		drawer.draw_ellipse(
			position, 
			radius,
			minor, 
			color
		)
#endregion


#region 编辑器相关方法
## 连接资源变化信号。
static func connect_resource_changed(resource: Resource, callable: Callable) -> void:
	if not resource:
		return

	var changed: Signal = resource.changed
	if changed.is_connected(callable):
		return

	changed.connect(callable)


## 连接资源变化信号并触发重绘。
static func resource_redraw_setter(drawer: CanvasItem, resource: Resource) -> void:
	if Engine.is_editor_hint():
		U.connect_resource_changed(resource, drawer.queue_redraw)
		drawer.queue_redraw()


## 触发重绘。
static func redraw_setter(drawer: CanvasItem) -> void:
	if Engine.is_editor_hint():
		drawer.queue_redraw()
#endregion
