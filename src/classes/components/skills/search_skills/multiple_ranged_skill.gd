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
	
	entity.facing_global_position = target.global_position
	start_cooldown(config)
	
	entity.play_animation(config.animation, &"ranged")
	AudioManager.play_sfx(config.sfx)
	if await entity.y_wait_animation(config.animation):
		compensate_cooldown(config)
		return

	for loop_index: int in config.loop_count:
		if not target:
			target = config.searcher.search_target(get_search_global_position(entity), entity)
			if not target:
				compensate_cooldown(config)
				return
				
		if not target:
			break
			
		entity.facing_global_position = target.global_position
		entity.play_animation(config.loop_animation)

		AudioManager.play_sfx(config.loop_sfx)
		if await entity.y_wait(config.delay):
			return

		_spawn_bullets(entity, target, config)
		if await entity.y_wait_animation(config.loop_animation):
			return

	if await entity.y_wait_animation(config.loop_animation):
		return

	entity.play_animation(config.end_animation)
	AudioManager.play_sfx(config.end_sfx)
	await entity.y_wait_animation(config.end_animation)
