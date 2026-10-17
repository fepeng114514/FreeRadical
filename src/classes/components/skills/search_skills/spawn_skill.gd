@tool
extends SearchSkill
class_name SpawnSkill
## 生成实体技能节点。
##
## [SpawnSkill] 会生成一个实体。


@export var config: SpawnSkillNodeConfig = null:
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
		if config.spawn_offsets:
			config.spawn_offsets.draw_offset_group(self)


func _use_skill(entity: Entity, target: Entity = null) -> void:
	if config.searcher:
		target = search_target(config, entity)
		if not target:
			return
			
	start_cooldown(config)
	AudioManager.play_sfx(config.sfx)

	var animated_sprite_c: AnimatedSpriteComponent = entity.get_node_or_null(Constants.ANIMATED_SPRITE_COMPONENT_NODE_PATH)
	var entity_global_position: Vector2 = entity.global_position
	var spawn_global_position: Vector2 = target.global_position if config.searcher else entity_global_position
	entity.facing_global_position = spawn_global_position
	if config.spawn_offsets:
		var spawn_offset: Vector2 = config.spawn_offsets.get_offset_toward_point(entity_global_position, spawn_global_position)
		spawn_global_position += spawn_offset
	entity.facing_global_position = spawn_global_position
	animated_sprite_c.play_animation(entity, config.animation, &"spawn")
	if await entity.y_wait(config.delay):
		compensate_cooldown(config)
		return

	if config.searcher and not target:
		target = search_target(config, entity)
		if not target:
			compensate_cooldown(config)
			return
		
		entity.facing_global_position = spawn_global_position
		animated_sprite_c.continue_play_new_animation(entity, config.animation, &"spawn")

	EntityManager.create_entities(config.spawns, 
		func(new_entity: Entity) -> void:
			new_entity.set_global_position_with_components(spawn_global_position)
			new_entity.source_id = entity.id
	)

	await animated_sprite_c.y_wait_animation(entity, config.animation)