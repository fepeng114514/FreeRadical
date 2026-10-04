@tool
extends BaseRangedSkill
class_name RangedSkill
## 单次远程技能节点。
##
## RangedSkill 会生成一个子弹，以子弹作为中介，对目标造成影响。子弹会以特定轨迹飞行，到达目标后造成影响。


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
	target = config.searcher.search_target(get_search_global_position(entity), entity)
	if not target:
		return
		
	entity.facing_global_position = target.global_position
	start_cooldown(config)

	entity.play_animation(config.animation, &"ranged")
	AudioManager.play_sfx(config.sfx)
	if await entity.y_wait(config.delay):
		compensate_cooldown(config)
		return

	if not target:
		target = config.searcher.search_target(get_search_global_position(entity), entity)
		if not target:
			compensate_cooldown(config)
			return

	_spawn_bullets(entity, target, config)

	await entity.y_wait_animation(config.animation)
