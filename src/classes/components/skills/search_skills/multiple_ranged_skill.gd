@tool
extends BaseRangedSkill
class_name MultipleRangedSkill
## 多次远程技能节点。
##
## MultipleRangedSkill 与 [RangedSkill] 相似，但是可以连续攻击多次。


@export var config: MultipleRangedSkillNodeConfig = null:
	set(v):
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()


func _draw() -> void:
	if not config:
		return

	if DebugManager.draw_range_enabled:
		if config.searcher:
			config.searcher.draw_search_range(self, position)

	if DebugManager.draw_offset_enabled:
		if config.bullet_offsets:
			config.bullet_offsets.draw_offset_group(self)


func _use_skill(entity: Entity, target: Entity = null) -> void:
	target = config.searcher.search_target(get_search_global_position(entity), entity)
	if not target:
		return
	
	start_cooldown(config)
	AudioManager.play_sfx(config.sfx)
	var animated_sprite_c: AnimatedSpriteComponent = entity.get_node_or_null(Constants.ANIMATED_SPRITE_COMPONENT_NODE_PATH)
	entity.facing_global_position = target.global_position
	animated_sprite_c.play_animation(entity, config.animation, &"ranged")
	if await animated_sprite_c.y_wait_animation(entity, config.animation):
		compensate_cooldown(config)
		return

	if not target:
		target = config.searcher.search_target(get_search_global_position(entity), entity)
		if not target:
			compensate_cooldown(config)

	if target:
		for loop_index: int in config.loop_count:
			AudioManager.play_sfx(config.loop_sfx)
			entity.facing_global_position = target.global_position
			animated_sprite_c.play_animation(entity, config.loop_animation, &"loop")
			if await entity.y_wait(config.delay):
				return

			if not target:
				target = config.searcher.search_target(get_search_global_position(entity), entity)
				if not target:
					break

				entity.facing_global_position = target.global_position
				animated_sprite_c.continue_play_new_animation(entity, config.loop_animation, &"loop")

			_spawn_bullets(entity, target, config)
			if await animated_sprite_c.y_wait_animation(entity, config.loop_animation):
				return

	AudioManager.play_sfx(config.end_sfx)
	if target:
		entity.facing_global_position = target.global_position
	animated_sprite_c.play_animation(entity, config.end_animation, &"end")
	await animated_sprite_c.y_wait_animation(entity, config.end_animation)
