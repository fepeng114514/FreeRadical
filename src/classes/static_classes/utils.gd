@abstract
extends Object
class_name Utils
## 工具函数库。


## 检查是否是有效数字。
static func is_valid_number(n: float) -> bool:
	return n != Constants.UNSET


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
		Utils.connect_resource_changed(resource, drawer.queue_redraw)
		drawer.queue_redraw()


## 触发重绘。
static func redraw_setter(drawer: CanvasItem) -> void:
	if Engine.is_editor_hint():
		drawer.queue_redraw()
#endregion
