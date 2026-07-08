extends PanelContainer
class_name GenerateTexture
## 生成 [SpriteFrames] 资源的工具，并自动按图集数据文件名创建子文件夹分类存放。


## 图集数据文件夹。
const DIR_SPRITE_FRAMES_DATAS: String = "res://tools/generate_texture/sprite_frames_datas/"
## 图集文件夹。
const DIR_ATLAS: String = "res://assets/atlas/"


## 缓存的图集纹理。
var cached_atlas: Dictionary[String, Texture2D] = {}
## 图像数据库。
var image_db: Dictionary[String, AtlasTexture] = {}


func _run() -> void:
	# 处理图集
	for file: String in U.open_directory(DIR_ATLAS).get_files():
		if file.get_extension() != "json":
			continue
			
		var full_path: String = DIR_ATLAS.path_join(file)
		Log.debug("处理图集: %s" % full_path)
		_parse_atlas_data(full_path)

	# 逐个处理 SpriteFrames 定义文件，生成并按分类保存 SpriteFrames
	for data_file: String in U.open_directory(DIR_SPRITE_FRAMES_DATAS).get_files():
		var full_path: String = DIR_SPRITE_FRAMES_DATAS.path_join(data_file)
		var json_data: Dictionary = U.load_json(full_path)
		var category: String = _get_category_from_path(full_path)
		_build_and_save_sprite_frames(category, json_data)


## 解析图集数据。
func _parse_atlas_data(path: String) -> void:
	var category: String = _get_category_from_path(path)
	var atlas_data: Dictionary = U.load_json(path)

	for atlas_name: String in atlas_data:
		var atlas_file: Texture2D = _load_atlas(DIR_ATLAS.path_join(atlas_name))

		var image_types: Dictionary = atlas_data[atlas_name]
		var atlas_texture_data_dict: Dictionary = image_types.atlas_texture

		for name: String in atlas_texture_data_dict:
			var img_data: Dictionary = atlas_texture_data_dict[name]
			var atlas_texture: AtlasTexture = _add_atlas_texture(name, atlas_file, img_data)
			_save_atlas_texture(category, name, atlas_texture)

		var sprite_frames_data_dict: Dictionary = image_types.sprite_frames

		for name: String in sprite_frames_data_dict:
			var img_data: Dictionary = sprite_frames_data_dict[name]
			_add_atlas_texture(name, atlas_file, img_data)


func _add_atlas_texture(name: String, atlas_file: Texture2D, img_data: Dictionary) -> AtlasTexture:
	var atlas_texture: AtlasTexture = _create_atlas_texture(img_data, atlas_file)

	# 设置修剪边距
	var trim: Array = img_data.trim
	var trim_x: int = trim[0]
	var trim_y: int = trim[1]
	var trim_w: int = trim_x + trim[2]
	var trim_h: int = trim_y + trim[3]
	atlas_texture.margin = Rect2(trim_x, trim_y, trim_w, trim_h)

	image_db[name] = atlas_texture

	# 处理别名
	for alias: String in img_data.alias:
		image_db[alias] = atlas_texture

	return atlas_texture


func _load_atlas(path: String) -> Texture2D:
	if cached_atlas.has(path):
		return cached_atlas[path]
	else:
		var atlas_file: Texture2D = load(path)
		cached_atlas[path] = atlas_file

		return atlas_file


## 从 JSON 数据创建 SpriteFrames 资源。
func _build_and_save_sprite_frames(category: String, json_data: Dictionary) -> void:
	for sprite_frames_name: String in json_data:
		var sprite_frames_info: Dictionary = json_data[sprite_frames_name]
		var is_layered: bool = (
			sprite_frames_info.has("layer_count") 
			and sprite_frames_info.layer_count > 0
		)
		var anim_group: Dictionary = sprite_frames_info.animations

		if is_layered:
			for layer_idx: int in range(1, sprite_frames_info.layer_count + 1):
				var layer_sprite_frames_name: String = "%s%d" % [sprite_frames_name, layer_idx]
				_process_and_save_sprite_frames(category, layer_sprite_frames_name, anim_group)
		else:
			_process_and_save_sprite_frames(category, sprite_frames_name, anim_group)


## 处理并保存 [SpriteFrames] 资源。
func _process_and_save_sprite_frames(category: String, sprite_frames_name: String, anim_group: Dictionary) -> void:
	var sprite_frames := SpriteFrames.new()
	sprite_frames.remove_animation("default")  # 移除默认的空动画

	for anim_name: String in anim_group:
		var anim_data: Dictionary = anim_group[anim_name]

		if sprite_frames.has_animation(anim_name):
			sprite_frames.clear(anim_name)
		else:
			sprite_frames.add_animation(anim_name)
			Log.verbose("增加动画: %s, 到 %s" % [anim_name, sprite_frames_name])

		var fps: float = anim_data.get("fps", 30)
		var loop: bool = anim_data.get("loop", true)
		sprite_frames.set_animation_speed(anim_name, fps)
		sprite_frames.set_animation_loop_mode(anim_name, SpriteFrames.LoopMode.LOOP_LINEAR if loop else SpriteFrames.LoopMode.LOOP_NONE)

		var from_idx: int = anim_data.from
		var to_idx: int = anim_data.to

		for idx: int in range(from_idx, to_idx + 1):
			var atlas_texture_name: String = "%s_%04d" % [sprite_frames_name, idx]
			if not image_db.has(atlas_texture_name):
				Log.warn("未找到帧: %s" % atlas_texture_name)
				continue
			var frame: AtlasTexture = image_db[atlas_texture_name]
			sprite_frames.add_frame(anim_name, frame)

	_save_sprite_frames(category, sprite_frames_name, sprite_frames)


## 创建图集纹理。
func _create_atlas_texture(img_data: Dictionary, atlas_file: Texture2D) -> AtlasTexture:
	var quad_data: Array = img_data["quad"]
	var atlas_texture: AtlasTexture = AtlasTexture.new()
	atlas_texture.atlas = atlas_file
	atlas_texture.region = Rect2(
		quad_data[0], quad_data[1], quad_data[2], quad_data[3]
	)
	atlas_texture.filter_clip = true
	return atlas_texture


## 保存图集纹理。
func _save_atlas_texture(category: String, atlas_texture_name: String, atlas_texture: AtlasTexture) -> void:
	var dir_path: String = "res://assets/atlas/atlas_textures/%s/" % category
	_ensure_directory(dir_path)
	var save_path: String = dir_path.path_join(atlas_texture_name + ".tres")
	ResourceSaver.save(atlas_texture, save_path)
	Log.info("生成 AtlasTexture: %s" % save_path)


## 保存 [SpriteFrames] 资源。
func _save_sprite_frames(category: String, sprite_frames_name: String, sprite_frames: SpriteFrames) -> void:
	var dir_path: String = "res://assets/atlas/sprite_frames/%s/" % category
	_ensure_directory(dir_path)
	var save_path: String = dir_path.path_join(sprite_frames_name + ".tres")
	ResourceSaver.save(sprite_frames, save_path)
	Log.info("生成 SpriteFrames: %s" % save_path)


## 确保目录存在。
func _ensure_directory(path: String) -> void:
	var dir := DirAccess.open("res://")
	if dir and not dir.dir_exists(path):
		dir.make_dir_recursive(path)


## 从路径中提取分类。
func _get_category_from_path(path: String) -> String:
	return path.get_file().get_basename()
