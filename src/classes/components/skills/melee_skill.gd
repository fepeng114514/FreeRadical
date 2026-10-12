@tool
extends Skill
class_name MeleeSkill
## 近战技能节点。
##
## [MeleeSkill] 与 [AreaSkill] 唯一区别的就是没有搜索目标这一步，需要被传入目标。[br]
## 主要用于 [MeleeComponent] 与 [DodgeComponent] 进行近战技能。


@export var config: MeleeSkillNodeConfig = null:
	set(v):
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()


func _draw() -> void:
	if not config:
		return
		
	if DebugManager.draw_range_enabled:
		if config.influence:
			config.influence.draw_influence_range(self, position)


func can_use(entity: Entity, _config: SkillNodeConfig, target: Entity = null) -> bool:
	if not super(entity, config, target):
		return false
		
	if not InteractPolicy.is_allowed_target(entity, target, config.interact_policy, target.config.interact_policy):
		return false
		
	return true


func _use_skill(entity: Entity, target: Entity = null) -> void:
	start_cooldown(config)
	AudioManager.play_sfx(config.sfx)
	var animated_sprite_c: AnimatedSpriteComponent = entity.get_node_or_null(Constants.ANIMATED_SPRITE_COMPONENT_NODE_PATH)
	entity.facing_global_position = target.global_position
	animated_sprite_c.play_animation(entity, config.animation, &"melee")
	if await entity.y_wait(config.delay) or not target or not target.state & Entity.State.MELEE:
		compensate_cooldown(config)
		return
	
	if config.search_at_target_position_enabled:
		config.influence.take_influence(entity, target, target.global_position)
	else:
		config.influence.take_influence(entity, target, entity.global_position)
	
	if await animated_sprite_c.y_wait_animation(entity, config.animation):
		return
		
	animated_sprite_c.play_idle_animation(entity)