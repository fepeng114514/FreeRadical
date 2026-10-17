@tool
extends BaseRangedSkill
class_name RangedSkill
## 单次远程技能节点。
##
## [RangedSkill] 会生成一个子弹，通过子弹对目标造成影响。


@export var config: RangedSkillNodeConfig = null:
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
	target = search_target(config, entity)
	if not target:
		return

	start_cooldown(config)
	AudioManager.play_sfx(config.sfx)
	var animated_sprite_c: AnimatedSpriteComponent = entity.get_node_or_null(Constants.ANIMATED_SPRITE_COMPONENT_NODE_PATH)
	entity.facing_global_position = target.global_position
	animated_sprite_c.play_animation(entity, config.animation, &"ranged")
	if await entity.y_wait(config.delay):
		compensate_cooldown(config)
		return

	if not target:
		target = search_target(config, entity)
		if not target:
			compensate_cooldown(config)
			return
		
		entity.facing_global_position = target.global_position
		animated_sprite_c.continue_play_new_animation(entity, config.animation, &"ranged")

	_spawn_bullets(entity, target, config)

	await animated_sprite_c.y_wait_animation(entity, config.animation)
