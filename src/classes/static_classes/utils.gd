@abstract
extends Object
class_name Utils
## 工具函数库。


## 检查是否是有效数字。
static func is_valid_number(n: float) -> bool:
	return n != Constants.UNSET


## 保存并加载资源。
static func save_and_load_resource(resource: Resource, save_path: String, type_hint: String = "", cache_mode: int = ResourceLoader.CACHE_MODE_REPLACE) -> Resource:
	ResourceSaver.save(resource, save_path)
	return ResourceLoader.load(save_path, type_hint, cache_mode)
			

#region 路径工具函数
## 打开目录。
static func open_directory(path: String) -> DirAccess:
	var dir: DirAccess = DirAccess.open(path)
	if not dir:
		Log.error(
			"无法打开目录: %s\n错误信息: %s" % [
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
		Log.error("JSON 文件不存在: %s" % path)
		return null
	
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if not file:
		Log.error("无法打开文件: %s" % path)
		return null
	
	var content: String = file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var parse_result: int = json.parse(content)
	
	if parse_result != OK:
		Log.error(
			"JSON 解析错误: %s\n错误行: %d" % [
				json.get_error_message(), json.get_error_line()
			]
		)
		return null
	
	return json.get_data()
	
	
## 保存 JSON 文件。
static func save_json(data: Variant, file_path: String) -> void:
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		Log.error("无法打开文件: %s\n错误信息: %s" % [
				file_path, FileAccess.get_open_error()
			]
		)
		return
		
	var json_string: String = JSON.stringify(data, "\t")
	file.store_string(json_string)
	file.close()
	Log.info("保存成功: %s" % file_path)
#endregion


## 从节点名称中提取组件名称
static func get_component_name(node_name: String) -> String:
	return node_name.replace("Component", "")


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
		width: float = 3,
		aspect: float = 0.7
	) -> void:
	var ranges := PackedFloat32Array([
		min_range,
		max_range
	])

	for radius: float in ranges:
		var minor: float = radius * aspect
		var major: float = radius

		drawer.draw_ellipse(
			position,
			major,
			minor,
			color,
			false,
			width
		)
		drawer.draw_ellipse(
			position,
			major,
			minor,
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
## 尝试连接或断开资源的变化信号。
static func rebind_changed(
		last_value: Resource, new_value: Resource, callable: Callable
	) -> void:
	if last_value:
		var last_changed_signal: Signal = last_value.changed
		if last_changed_signal.is_connected(callable):
			last_changed_signal.disconnect(callable)

	if new_value:
		var new_changed_signal: Signal = new_value.changed
		if not new_changed_signal.is_connected(callable):
			new_changed_signal.connect(callable)


## 连接资源的变化信号。
static func connect_property_signals(object: Object, properties: Dictionary[String, Callable]) -> void:
	for prop_name: String in properties:
		var callable: Callable = properties[prop_name]

		var prop_value := object.get(prop_name) as Resource
		if not prop_value:
			continue

		var prop_changed_signal: Signal = prop_value.changed
		if prop_changed_signal.is_connected(callable):
			continue

		prop_changed_signal.connect(callable)
#endregion
