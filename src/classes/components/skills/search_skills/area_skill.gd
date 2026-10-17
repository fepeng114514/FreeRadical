@tool
extends SearchSkill
class_name AreaSkill
## 范围技能节点。
##
## [AreaSkill] 会以目标实体为中心造成影响。


@export var config: AreaSkillNodeConfig = null:
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

	if DebugManager.draw_range_enabled:
		if config.influence:
			config.influence.draw_influence_range(self, position)

		
func _use_skill(entity: Entity, target: Entity = null) -> void:
	var animated_sprite_c: AnimatedSpriteComponent = entity.get_node_or_null(Constants.ANIMATED_SPRITE_COMPONENT_NODE_PATH)
	
	if config.searcher:
		target = search_target(config, entity)
		if not target:
			return
	
		entity.facing_global_position = target.global_position
		
	start_cooldown(config)
	AudioManager.play_sfx(config.sfx)
	animated_sprite_c.play_animation(entity, config.animation, &"area")
	if await entity.y_wait(config.delay) or config.searcher and not target:
		compensate_cooldown(config)
		return

	if config.searcher:
		if not target:
			target = search_target(config, entity)
			if not target:
				compensate_cooldown(config)
				return

			entity.facing_global_position = target.global_position
			animated_sprite_c.continue_play_new_animation(entity, config.animation, &"area")
			
		config.influence.take_influence(entity, target, target.global_position)
	else:
		config.influence.take_influence(entity, entity, entity.global_position)

	if await animated_sprite_c.y_wait_animation(entity, config.animation):
		return
		
	animated_sprite_c.play_idle_animation(entity)
