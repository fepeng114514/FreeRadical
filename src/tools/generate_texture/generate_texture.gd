@tool
extends EditorScript
#class_name GenerateTexture
## 生成 [SpriteFrames] 资源的工具，并自动按图集数据文件名创建子文件夹分类存放。


## 图集数据文件夹。
const DIR_SPRITE_FRAMES_DATAS: String = "res://tools/generate_texture/sprite_frames_datas/"
## 图集文件夹。
const DIR_ATLAS: String = "res://assets/atlas/"


var atlas_texture_db: Dictionary[String, AtlasTextureItem] = {}
var sprite_frames_texture_db: Dictionary[String, AtlasTexture] = {}
var sprite_frames_dict: Dictionary[String, SpriteFramesItem] = {}


func _run() -> void:
	_parse_atlas_datas()
	_generate_atlas_texture()

	_build_all_sprite_frames()
	_generate_sprite_frames()


## 解析图集数据文件。
func _parse_atlas_datas() -> void:
	for atlas_data_file: String in U.open_directory(DIR_ATLAS).get_files():
		if atlas_data_file.get_extension() != "json":
			continue
			
		atlas_data_file = DIR_ATLAS.path_join(atlas_data_file)

		Log.debug("处理图集数据文件: %s" % atlas_data_file)
		var atlas_data: Dictionary = U.load_json(atlas_data_file)

		for atlas_name: String in atlas_data:
			var atlas_file: String = atlas_data_file.get_base_dir().path_join(atlas_name)
			var atlas: Texture2D = load(atlas_file)

			var types: Dictionary = atlas_data[atlas_name]

			# 处理图集纹理
			var atlas_texture_data_dict: Dictionary = types.atlas_texture
			for texture_name: String in atlas_texture_data_dict:
				var texture_data: Dictionary = atlas_texture_data_dict[texture_name]
				var atlas_texture: AtlasTexture = _create_texture(atlas, texture_data)
				atlas_texture_db[texture_name] = AtlasTextureItem.new(atlas_texture, atlas_data_file.get_file().get_basename())

			# 处理 SpriteFrames 的纹理
			var sprite_frames_data_dict: Dictionary = types.sprite_frames
			for texture_name: String in sprite_frames_data_dict:
				var texture_data: Dictionary = sprite_frames_data_dict[texture_name]
				var sprite_frames_texture: AtlasTexture = _create_texture(atlas, texture_data)
				sprite_frames_texture_db[texture_name] = sprite_frames_texture

				# 处理别名
				for alias: String in texture_data.alias:
					sprite_frames_texture_db[alias] = sprite_frames_texture


## 创建图集纹理。
func _create_texture(atlas: Texture2D, texture_data: Dictionary) -> AtlasTexture:
	var atlas_texture: AtlasTexture = AtlasTexture.new()
	atlas_texture.atlas = atlas

	var quad_data: Array = texture_data["quad"]
	atlas_texture.region = Rect2(
		quad_data[0], quad_data[1], quad_data[2], quad_data[3]
	)
	atlas_texture.filter_clip = true

	# 设置修剪边距
	var trim: Array = texture_data.trim
	var trim_x: int = trim[0]
	var trim_y: int = trim[1]
	var trim_w: int = trim_x + trim[2]
	var trim_h: int = trim_y + trim[3]
	atlas_texture.margin = Rect2(trim_x, trim_y, trim_w, trim_h)

	return atlas_texture


## 确保目录存在。
func _ensure_directory(path: String) -> void:
	var dir := DirAccess.open("res://")
	if dir and not dir.dir_exists(path):
		dir.make_dir_recursive(path)

		
## 生成 [AtlasTexture] 资源。
func _generate_atlas_texture() -> void:
	for atlas_texture_name: String in atlas_texture_db:
		var atlas_texture_item: AtlasTextureItem = atlas_texture_db[atlas_texture_name]

		var dir_path: String = "res://assets/atlas/atlas_textures/%s/" % atlas_texture_item.category
		_ensure_directory(dir_path)
		var save_path: String = dir_path.path_join(atlas_texture_name + ".tres")

		ResourceSaver.save(atlas_texture_item.atlas_texture, save_path)
		Log.info("生成 AtlasTexture: %s" % save_path)


## 从精灵帧数据数据构建 [SpriteFrames] 资源。
func _build_all_sprite_frames() -> void:
	for dir_name: String in U.open_directory(DIR_SPRITE_FRAMES_DATAS).get_directories():
		var dir_path: String = DIR_SPRITE_FRAMES_DATAS.path_join(dir_name)
		for sprite_frames_file: String in U.open_directory(dir_path).get_files():
			if sprite_frames_file.get_extension() != "tres":
				continue

			var full_path: String = dir_path.path_join(sprite_frames_file)
			var sprite_frames_data: SpriteFramesData = load(full_path)
			var animation_dict: Dictionary[String, SpriteFramesAnimationData] = sprite_frames_data.animation_dict
			
			var sprite_frames_name: String = sprite_frames_file.get_basename()
			
			var layer_count: int = sprite_frames_data.layer_count
			if layer_count > 0:
				for layer_idx: int in range(1, layer_count + 1):
					var layer_sprite_frames_name: String = "%s%d" % [sprite_frames_name, layer_idx]
					var sprite_frames: SpriteFrames = _create_sprite_frames(layer_sprite_frames_name, animation_dict)
					sprite_frames_dict[layer_sprite_frames_name] = SpriteFramesItem.new(sprite_frames, dir_name)
			else:
				var sprite_frames: SpriteFrames = _create_sprite_frames(sprite_frames_name, animation_dict)
				sprite_frames_dict[sprite_frames_name] = SpriteFramesItem.new(sprite_frames, dir_name)


## 创建 [SpriteFrames] 资源。
func _create_sprite_frames(sprite_frames_name: String, animation_dict: Dictionary[String, SpriteFramesAnimationData]) -> SpriteFrames:
	var sprite_frames := SpriteFrames.new()
	sprite_frames.remove_animation("default")  # 移除默认的空动画
		
	for anim_name: String in animation_dict:
		if sprite_frames.has_animation(anim_name):
			sprite_frames.clear(anim_name)
		else:
			sprite_frames.add_animation(anim_name)
			Log.verbose("%s 增加动画: %s" % [sprite_frames_name, anim_name])

		var anim_data: SpriteFramesAnimationData = animation_dict[anim_name]
		sprite_frames.set_animation_speed(anim_name, anim_data.fps)
		sprite_frames.set_animation_loop_mode(anim_name, anim_data.loop_mode)

		for idx: int in range(anim_data.from, anim_data.to + 1):
			var atlas_texture_name: String = "%s_%04d" % [sprite_frames_name, idx]
			if not sprite_frames_texture_db.has(atlas_texture_name):
				Log.error("未找到精灵帧纹理: %s" % atlas_texture_name)
				continue

			var frame: AtlasTexture = sprite_frames_texture_db[atlas_texture_name]
			sprite_frames.add_frame(anim_name, frame)

	return sprite_frames


## 生成 [SpriteFrames] 资源。
func _generate_sprite_frames() -> void:
	for sprite_frames_name: String in sprite_frames_dict:
		var sprite_frames_item: SpriteFramesItem = sprite_frames_dict[sprite_frames_name]

		var dir_path: String = "res://assets/atlas/sprite_frames/%s/" % sprite_frames_item.category
		_ensure_directory(dir_path)
		var save_path: String = dir_path.path_join(sprite_frames_name + ".tres")

		ResourceSaver.save(sprite_frames_item.sprite_frames, save_path)
		Log.info("生成 SpriteFrames: %s" % save_path)


class AtlasTextureItem:
	var atlas_texture: AtlasTexture = null
	var category: String = ""

	func _init(p_atlas_texture: AtlasTexture, p_category: String):
		self.atlas_texture = p_atlas_texture
		self.category = p_category


class SpriteFramesItem:
	var sprite_frames: SpriteFrames = null
	var category: String = ""

	func _init(p_sprite_frames: SpriteFrames, p_category: String):
		self.sprite_frames = p_sprite_frames
		self.category = p_category
