@tool
extends SearchSkill
class_name AreaSkill
## 范围技能节点。
##
## AreaSkill 会搜索到第一个目标实体，然后对它造成影响。[br]
## 与 [RangedSkill] 不同，AreaSkill 不会创建子弹作为中介，而是直接对目标实体造成影响。[br]
## 相当于对 [Influence] 封装了一个搜索目标的机制，以搜索到的第一个目标为中心造成影响。


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
	if config.searcher:
		target = config.searcher.search_target(get_search_global_position(entity), entity)
		if not target:
			return
	
		entity.facing_global_position = target.global_position
	start_cooldown(config)

	entity.play_animation(config.animation)
	AudioManager.play_sfx(config.sfx)
	if await entity.y_wait(config.delay) or config.searcher and not target:
		compensate_cooldown(config)
		return

	if config.searcher:
		if not target:
			target = config.searcher.search_target(get_search_global_position(entity), entity)
			if not target:
				compensate_cooldown(config)
				return
		
		config.influence.take_influence(entity, target, target.global_position)
	else:
		config.influence.take_influence(entity, entity, entity.global_position)

	if await entity.y_wait_animation(config.animation):
		return
		
	entity.play_animation(entity.config.idle_animation, &"idle")
