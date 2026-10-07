@tool
extends Node2D
class_name Entity
## 实体节点。
##
## 实体节点存储实体的基本属性和组件。[br][br]
## 游戏中所有具有行为和属性的对象都可以被表示为 Entity，例如: 敌人、友军、防御塔、子弹、修改器等。


@warning_ignore_start("unused_signal")
## 实体移除信号，当实体准备从场景中移除时触发。
signal entity_removing
@warning_ignore_restore("unused_signal")


## 实体状态枚举
enum State {
	## 实体状态：空闲。
	IDLE = 1,
	## 实体状态：拦截敌人中。
	MELEE = 1 << 1,
	## 实体状态：释放远程技能中。
	RANGED = 1 << 2,
	## 实体状态：前往集结点。
	RALLY = 1 << 3,
	## 实体状态：在路径上移动。
	NAV_PATH_WALK = 1 << 4,
	## 实体状态：闪避。
	DODGE = 1 << 5,

	## 实体状态：死亡。
	DEAD = 1 << 10,

	## 实体状态：被禁止。
	DISABLED = 1 << 20,
	## 实体状态：被移除。
	REMOVED = 1 << 21,
	## 实体状态：阻塞中。
	BLOCKING = 1 << 22,
	## 实体状态：等待中。
	WAITING = 1 << 23,
	## 实体状态：中断等待。
	INTERRUPT_WAIT = 1 << 24,
}


## 实体元状态枚举。
enum MetaState {
	## 实体元状态：无。
	NONE = 0,
	## 实体元状态：注定死亡。
	DOOMED = 1,
}


## 来源类型枚举。
enum SourceType {
	## 来源类型：无
	NONE,
	## 来源类型：防御塔射手
	TOWER_SHOOTER,
	## 来源类型：兵营
	BARRACK_SOLDIER,
}


#region 属性
## 更新节点配置模板按钮。
@export_tool_button("更新节点配置模板") var update_config_template: Callable = _update_config_template
## 节点配置模板。
@export var node_config_template: NodeConfigTemplateNode = null:
	set(v):
		node_config_template = v
		update_configuration_warnings()
## 节点配置。
@export var config: EntityNodeConfig = null:
	set(v):
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()

## 实体场景名称
var scene_name: String = ""
## 实体本地化名称
var localization_key: String = ""
## 实体唯一 ID
var id: int = Constants.UNSET
## 所有者或来源 ID
var source_id: int = Constants.UNSET
## 来源类型
var source_type: SourceType = SourceType.NONE
## 插入时间戳，单位为秒
var inserted_time_stamp: float = 0.0
## 时间戳，单位为秒
var time_stamp: float = 0.0
## 目标实体 ID
var target_id: int = Constants.UNSET
## 拥有的修改器 ID 列表
var has_mods_ids := PackedInt32Array()
## 上次拥有的修改器 ID 列表长度，用于检测列表的变化。
var last_has_mods_ids_size: int = 0
## 拥有的光环 ID 列表
var has_auras_ids := PackedInt32Array()
## 以此实体为目标的子弹 ID 列表
var aimed_bullet_ids := PackedInt32Array()
## 是否有新的子弹以此实体为目标。
var has_new_aimed_bullet: bool = false
## 是否被点击选择
var selected: bool = false
## 上一帧全局位置
var last_global_position := Vector2.ZERO
## 状态
var state: int = Entity.State.IDLE
## 元状态
var meta_state: int = Entity.MetaState.NONE
## 面朝的全局位置
var facing_global_position := Vector2.INF
## 是否是首次更新
var is_first_update: bool = true
## 实体属于的实体组。
var entity_groups: Array[StringName] = []

## 拥有的所有组件节点引用
var components: Dictionary[StringName, Component] = {}
#endregion


func _ready() -> void:
	scene_name = scene_file_path.get_file().get_basename()
	localization_key = scene_name.to_upper()

	for child: Node in get_children():
		if not child is Component:
			continue

		var node_script: GDScript = child.get_script()
		var node_class_name: StringName = node_script.get_global_name()
			
		components[node_class_name] = child
		
	if config:
		if config.interact_policy:
			set_entity_groups(config.interact_policy.get_entity_group_names())

	DebugManager.draw_state_changed.connect(_on_draw_state_changed)


func _draw() -> void:
	if DebugManager.draw_offset_enabled:
		if config:
			if config.hit_offsets:
				config.hit_offsets.draw_offset_group(self)
			if config.aura_offsets:
				config.aura_offsets.draw_offset_group(self)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = NodeConfigManager.get_common_configuration_warnings(self)
		
	if EditorInterface.get_edited_scene_root() == self:
		if node_config_template:
			if not FileAccess.file_exists(node_config_template.resource_path):
				warnings.append("请将 node_config_template 节点配置模板保存为文件，否则后续无法在节点配置管理器中索引该实体的节点配置模板。")
		else:
			warnings.append("请设置一个 node_config_template 节点配置模板，或点击实体的 “更新节点配置模板” 按钮一键生成。")

	return warnings


func _to_string():
	return String(name)


## 获取本土化名称
func get_localized_name() -> String:
	return tr(scene_name.to_upper())

	
## 设置实体组。
func set_entity_groups(groups: Array[StringName]) -> void:
	entity_groups = groups


## 增加实体组件。
func add_component(component: Component) -> void:
	var component_class_name: StringName = component.get_class()
	components[component_class_name] = component


## 移除实体组件。
func remove_component(component: Component) -> void:
	var component_class_name: StringName = component.get_class()
	components.erase(component_class_name)


#region 实体相关方法
## 设置实体全局位置，根据拥有的组件智能赋值
func set_global_position_with_components(new_global_position: Vector2) -> void:
	global_position = new_global_position
	
	var rally_c: RallyComponent = get_node_or_null(Constants.RALLY_COMPONENT_NODE_PATH)
	if rally_c:
		rally_c.new_rally_global_position(self, new_global_position)
	
	var nav_path_c: NavPathComponent = get_node_or_null(Constants.NAV_PATH_COMPONENT_NODE_PATH)
	if nav_path_c:
		nav_path_c.set_nav_path_to_nearest_node(self, new_global_position)


func is_waiting() -> bool:
	return state & (Entity.State.BLOCKING | Entity.State.WAITING | Entity.State.DISABLED)


## 协程等待指定时长。[br][br]
## [param break_fn]: 中断函数。返回 [code]true[/code] 表示中断等待。
## -> 等待是否被中断。
func y_wait(time: float = 0.0, break_fn: Callable = Callable()) -> bool:
	state |= Entity.State.WAITING

	Log.verbose("实体等待: %s, %.2fs" % [self, time])
	if time <= 0:
		return false

	var timestamp: float = TimeManager.tick_time_stamp
	var is_break: bool = false
	while not TimeManager.has_elapsed(timestamp, time):
		is_break = (
			not is_inside_tree()
			or state & Entity.State.INTERRUPT_WAIT 
			or break_fn.is_valid() and break_fn.call()
		)
		if is_break:
			Log.verbose("%s 中断等待: %.2fs" % [self, time])
			break

		await get_tree().process_frame

	Log.verbose("实体等待完毕: %s, %.2fs" % [self, time])

	state &= ~(Entity.State.WAITING | Entity.State.INTERRUPT_WAIT)
	return is_break
#endregion


#region 修改器相关方法
## 获取拥有的所有修改器实体数组
func get_has_mod_list(filter: Callable = Callable()) -> Array[Entity]:
	var has_mods: Array[Entity] = []
	
	for mod_id: int in has_mods_ids:
		var mod: Entity = EntityManager.get_entity_by_id(mod_id)
		
		if not mod or filter.is_valid() and not filter.call(mod):
			continue
		
		has_mods.append(mod)
		
	return has_mods


## 清空拥有的修改器
func clear_has_mod_list() -> void:
	for mod: Entity in get_has_mod_list():
		EntityManager.queue_remove_entity(mod)

	has_mods_ids.clear()
#endregion


#region 光环相关方法
## 获取拥有的光环实体数组
func get_has_aura_list(filter: Callable = Callable()) -> Array[Entity]:
	var has_auras: Array[Entity] = []
	
	for aura_id in has_auras_ids:
		var aura: Entity = EntityManager.get_entity_by_id(aura_id)
		
		if not aura or filter.is_valid() and not filter.call(aura):
			continue
		
		has_auras.append(aura)
		
	return has_auras


## 清空拥有的光环
func clear_has_aura_list() -> void:
	for aura: Entity in get_has_aura_list():
		EntityManager.queue_remove_entity(aura)

	has_auras_ids.clear()
#endregion


#region 动画相关方法
## 播放动画
func play_animation(
		animation_group: AnimationGroup, 
		source_animation_key: String = "",
		force_play: bool = false
	) -> AnimationData:
	if not animation_group:
		return null
		
	var play_index: int = animation_group.play_index
	var sprite_c: SpriteComponent = get_node_or_null(Constants.SPRITE_COMPONENT_NODE_PATH)
	
	var play_target: Node2D = sprite_c.get_child(play_index)
	if play_target is Sprite2D:
		return null

	var anim_data: AnimationData = animation_group.get_animation_name_toward_point(
		global_position, facing_global_position
	)
	
	var anim_name: StringName = anim_data.anim_name
	var filp_h: bool = anim_data.flip_h

	if play_target is SpriteGroup:
		_play_animation_in_group(anim_name, play_target, filp_h, animation_group.speed_scale, force_play)
	else:
		_play_animation(anim_name, play_target, filp_h, animation_group.speed_scale, force_play)

	## 处理同步动画
	if sprite_c.config.sync_source:
		var source: Entity = EntityManager.get_entity_by_id(source_id)
		if source and not is_waiting():
			source.facing_global_position = facing_global_position
			var s_sprite_c: SpriteComponent = source.get_node_or_null(Constants.SPRITE_COMPONENT_NODE_PATH)
			var s_animation: AnimationGroup = s_sprite_c.config.sync_animations.get(
				source_animation_key
			)
			if s_animation:
				source.play_animation(
					s_animation, source_animation_key, force_play
				)
				source.y_wait_animation(s_animation)

	return anim_data


## 获取动画剩余帧数
func get_frames_remaining(play_target: AnimatedSprite2D) -> int:
	var current_frame: int = play_target.frame
	var total_frames: int = play_target.sprite_frames.get_frame_count(play_target.animation)

	return total_frames - current_frame


## 获取当前播放的动画
func get_current_animation(animation_group: AnimationGroup) -> AnimatedSprite2D:
	var sprite_c: SpriteComponent = get_node_or_null(Constants.SPRITE_COMPONENT_NODE_PATH)
	var play_index: int = animation_group.play_index

	var play_target: Node2D = sprite_c.get_child(play_index)
	if play_target is SpriteGroup:
		play_target = play_target.get_child(play_index)
	elif not play_target is AnimatedSprite2D:
		return null
		
	return play_target


## 获取动画总时间
func get_animation_total_time(animation_group: AnimationGroup) -> float:
	if not animation_group:
		return 0

	var play_target: AnimatedSprite2D = get_current_animation(animation_group)
	if not play_target:
		return 0

	var sprite_frames: SpriteFrames = play_target.sprite_frames
	var animation_name: StringName = play_target.animation
	var total_frames: int = sprite_frames.get_frame_count(animation_name)
	
	return total_frames / sprite_frames.get_animation_speed(animation_name)


## 获取动画剩余时间
func get_animation_remaining_time(animation_group: AnimationGroup) -> float:
	if not animation_group:
		return 0

	var play_target: AnimatedSprite2D = get_current_animation(animation_group)
	if not play_target:
		return 0

	var sprite_frames: SpriteFrames = play_target.sprite_frames
	var animation_name: StringName = play_target.animation

	return get_frames_remaining(play_target) / sprite_frames.get_animation_speed(animation_name)


## 协程等待动画播放完成。[br]
## [param break_fn] 中断函数。返回 [code]true[/code] 表示中断等待。
## -> 等待是否被中断。
func y_wait_animation(animation_group: AnimationGroup, break_fn: Callable = Callable()) -> bool:
	if not animation_group:
		return false
		
	var play_target: AnimatedSprite2D = get_current_animation(animation_group)
	if not play_target:
		return false
			
	var frames_remaining: int = get_frames_remaining(play_target)
	var loop_mode: SpriteFrames.LoopMode = play_target.sprite_frames.get_animation_loop_mode(play_target.animation)
	var times: int = animation_group.times

	state |= Entity.State.WAITING
	var is_break: bool = false
	for _i: int in times:
		for j: int in frames_remaining:
			is_break = (
				state & Entity.State.INTERRUPT_WAIT 
				or break_fn.is_valid() 
				and break_fn.call()
			)
			if is_break:
				break

			if (
				loop_mode == SpriteFrames.LoopMode.LOOP_NONE 
				and j == frames_remaining - 1
			):
				await play_target.animation_finished
			else:
				await play_target.frame_changed

		if is_break:
			Log.verbose("%s 中断等待动画: %s" % [self, play_target.animation])
			break

	state &= ~(Entity.State.WAITING | Entity.State.INTERRUPT_WAIT)
	return is_break
#endregion


## 使一个精灵播放动画
func _play_animation(
		anim_name: StringName, 
		sprite: AnimatedSprite2D, 
		filp_h: bool = false,
		speed_scale: float = 1.0,
		force_play: bool = false
	) -> void:
	if (
			not force_play 
			and sprite.animation == anim_name 
			and sprite.flip_h == filp_h
		):
		return

	var sprite_frames: SpriteFrames = sprite.sprite_frames
		
	if not sprite_frames.has_animation(anim_name):
		Log.error("%s 未找到动画: %s" % [self, anim_name])
		return
		
	Log.verbose("%s 播放动画: %s, 水平镜像: %s" % [self, anim_name, filp_h])
	sprite.flip_h = filp_h
	sprite.speed_scale = speed_scale
	sprite.play(anim_name)
	
	
## 使一个精灵组中的所有精灵播放对应的动画
func _play_animation_in_group(
		anim_name: StringName, 
		group: SpriteGroup, 
		filp_h: bool = false,
		speed_scale: float = 1.0,
		force_play: bool = false
	) -> void:
	for sprite: AnimatedSprite2D in group.get_children():
		_play_animation(anim_name, sprite, filp_h, speed_scale, force_play)	
		
		
func _update_config_template() -> void:
	var scene_file_dir: String = scene_file_path.get_base_dir()
	var template_dir: String = scene_file_dir.path_join("template")
	DirAccess.make_dir_absolute(template_dir)

	var new_config_template := NodeConfigTemplateNode.new()

	if not config:
		var new_config: NodeConfig = EntityNodeConfig.new()
		var save_path: String = template_dir.path_join("%s.tres" % name.to_snake_case())
		new_config = Utils.save_and_load_resource(new_config, save_path)
		config = new_config

	new_config_template.config = config
		
	_build_config_template_node_recursive(self, new_config_template, template_dir)

	var root_save_path: String = template_dir.path_join("node_config_template.tres")
	node_config_template = Utils.save_and_load_resource(new_config_template, root_save_path)
	Log.info("生成配置模板: %s" % root_save_path)
	EditorInterface.mark_scene_as_unsaved()


func _build_config_template_node_recursive(node: Node, current_config_template_parent: NodeConfigTemplateNode, template_dir: String) -> void:
	for child: Node in node.get_children():
		if child is Entity:
			continue

		var config_prop: Dictionary = {}
		for prop: Dictionary in child.get_property_list():
			if prop.name != "config":
				continue

			config_prop = prop
			break

		if config_prop.is_empty():
			continue
		
		var node_name: String = child.name
		var node_path: NodePath = get_path_to(child)
		var save_dir: String = template_dir.path_join(String(node_path).to_snake_case()).simplify_path()
		DirAccess.make_dir_absolute(save_dir)

		var config_template_node := NodeConfigTemplateNode.new()
		config_template_node.name = node_name
		
		if child.config:
			config_template_node.config = child.config
		else:
			var cls_name: StringName = config_prop.class_name
			var cls: Dictionary = GlobalManager.global_classes[cls_name]
			var new_config: NodeConfig = load(cls.path).new()
			
			var save_path: String = save_dir.path_join("%s.tres" % node_name.to_snake_case())
			new_config = Utils.save_and_load_resource(new_config, save_path)
			child.config = new_config
			config_template_node.config = new_config
			Log.verbose("创建配置: %s" % save_path)

		current_config_template_parent.add_child(config_template_node)
		_build_config_template_node_recursive(child, config_template_node, template_dir)


func _on_draw_state_changed(_draw_type: DebugManager.DrawType) -> void:
	queue_redraw()


func _on_config_changed() -> void:
	if config:
		if config.interact_policy:
			set_entity_groups(config.interact_policy.get_entity_group_names())
		
	queue_redraw()
