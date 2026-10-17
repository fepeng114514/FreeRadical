@tool
extends Component
class_name AnimatedSpriteComponent
## 动画精灵组件。
##
## [AnimatedSpriteComponent] 可以让实体可以显示 [AnimatedSprite2D] 动画精灵节点。


@export var config: AnimatedSpriteComponentNodeConfig = null:
	set(v):
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()


func _ready() -> void:
	super()
	
	show_behind_parent = true
	process_mode = Node.PROCESS_MODE_INHERIT


## 播放空闲动画，见 [AnimatedSpriteComponent.play_animation]。
func play_idle_animation(entity: Entity, force_play: bool = false) -> AnimationData:
	return play_animation(entity, config.idle_animation, &"idle", force_play)


## 从上次播放到的位置继续播放新动画，见 [AnimatedSpriteComponent.play_animation]。
func continue_play_new_animation(
		entity: Entity,
		animation_group: AnimationGroup, 
		source_animation_key: String = "",
		force_play: bool = false
	) -> AnimationData:
	var last_animated_sprite: AnimatedSprite2D = get_playing_animated_sprite(animation_group)
	var last_frame: int = last_animated_sprite.frame
	var last_progress: float = last_animated_sprite.progress
	var anim_data: AnimationData = play_animation(entity, animation_group, source_animation_key, force_play)
	var current_animated_sprite: AnimatedSprite2D = get_playing_animated_sprite(animation_group)
	current_animated_sprite.set_frame_and_progress(last_frame, last_progress)
	
	return anim_data


## 播放新动画。
func play_animation(
		entity: Entity,
		animation_group: AnimationGroup, 
		source_animation_key: String = "",
		force_play: bool = false
	) -> AnimationData:
	if not animation_group:
		return null
		
	var play_index: int = animation_group.play_index
	var player: Node2D = get_child(play_index)
	var anim_data: AnimationData = animation_group.get_animation_name_toward_point(
		entity.global_position, entity.facing_global_position
	)
	
	var anim_name: StringName = anim_data.anim_name
	var filp_h: bool = anim_data.flip_h

	if player is SpriteGroup:
		_play_animation_in_group(anim_name, player, filp_h, animation_group.speed_scale, force_play)
	else:
		_play_animation(anim_name, player, filp_h, animation_group.speed_scale, force_play)

	# 处理同步动画。
	if config.sync_source:
		var source: Entity = EntityManager.get_entity_by_id(entity.source_id)
		if source and not source.is_waiting():
			var s_animated_sprite_c: AnimatedSpriteComponent = source.get_node_or_null(Constants.ANIMATED_SPRITE_COMPONENT_NODE_PATH)
			var s_animation: AnimationGroup = s_animated_sprite_c.config.sync_animations.get(
				source_animation_key
			)
			if s_animation:
				s_animated_sprite_c.play_animation(source, s_animation, source_animation_key, force_play)
				s_animated_sprite_c.y_wait_animation(source, s_animation)

	return anim_data


## 获取动画精灵剩余帧数。
func get_frames_remaining(animated_sprite: AnimatedSprite2D) -> int:
	var current_frame: int = animated_sprite.frame
	var total_frames: int = animated_sprite.sprite_frames.get_frame_count(animated_sprite.animation)

	return total_frames - current_frame


## 获取当前播放的动画精灵。
func get_playing_animated_sprite(animation_group: AnimationGroup) -> AnimatedSprite2D:
	var play_index: int = animation_group.play_index

	var player: Node2D = get_child(play_index)
	if player is SpriteGroup:
		player = player.get_child(play_index)
	elif not player is AnimatedSprite2D:
		return null
		
	return player


## 协程等待动画播放完成。[br]
## [param break_fn] 中断函数。返回 [code]true[/code] 表示中断等待。
## -> 等待是否被中断。
func y_wait_animation(
		entity: Entity,
		animation_group: AnimationGroup, break_fn: Callable = Callable()) -> bool:
	if not animation_group:
		return false
		
	var animated_sprite: AnimatedSprite2D = get_playing_animated_sprite(animation_group)
	if not animated_sprite:
		return false
			
	var frames_remaining: int = get_frames_remaining(animated_sprite)
	var loop_mode: SpriteFrames.LoopMode = animated_sprite.sprite_frames.get_animation_loop_mode(animated_sprite.animation)
	var times: int = animation_group.times

	entity.state |= Entity.State.WAITING
	var is_break: bool = false
	for _i: int in times:
		for j: int in frames_remaining:
			is_break = (
				entity.state & Entity.State.INTERRUPT_WAIT 
				or break_fn.is_valid() 
				and break_fn.call()
			)
			if is_break:
				break

			# 非循环动画最后一帧的 frame_changed 永远不会发出，需要等待 animation_finished
			if (
				loop_mode == SpriteFrames.LoopMode.LOOP_NONE 
				and j == frames_remaining - 1
			):
				await animated_sprite.animation_finished
			else:
				await animated_sprite.frame_changed

		if is_break:
			Log.verbose("%s 中断等待动画: %s" % [self, animated_sprite.animation])
			break

	entity.state &= ~(Entity.State.WAITING | Entity.State.INTERRUPT_WAIT)
	return is_break


## 使一个精灵播放动画。
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
		Log.error("%s 未找到动画: %s" % [parent, anim_name])
		return
		
	Log.verbose("%s 播放动画: %s, 水平镜像: %s" % [parent, anim_name, filp_h])
	sprite.flip_h = filp_h
	sprite.speed_scale = speed_scale
	sprite.play(anim_name)
	
	
## 使一个精灵组中的所有精灵播放对应的动画。
func _play_animation_in_group(
		anim_name: StringName, 
		group: SpriteGroup, 
		filp_h: bool = false,
		speed_scale: float = 1.0,
		force_play: bool = false
	) -> void:
	for sprite: AnimatedSprite2D in group.get_children():
		_play_animation(anim_name, sprite, filp_h, speed_scale, force_play)	
		
