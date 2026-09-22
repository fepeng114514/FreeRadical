@tool
extends Skill
class_name MeleeSkill
## 近战技能节点。
##
## MeleeSkill 与 [AreaSkill] 唯一区别的就是没有搜索目标这一步，需要被传入目标。[br]
## 主要用于 [MeleeComponent] 与 [DodgeComponent] 进行近战技能。


@export var config: MeleeSkillNodeConfig = null:
	set(v):
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()

## 影响资源，用于对目标造成伤害或治愈目标。
@export var influence: Influence = null
## 是否启用搜索第一个目标位置，如果为 false 则以释放者的位置为中心造成影响，而非第一个目标的位置。
@export var search_at_target_position_enabled: bool = false
## 交互策略。
@export var interact_policy: InteractPolicy = null


func _draw() -> void:
	if DebugManager.draw_range_enabled:
		if influence:
			influence.draw_influence_range(self, position)


func can_use(entity: Entity, target: Entity = null) -> bool:
	if not super(entity):
		return false
		
	if not InteractPolicy.is_allowed_target(entity, target, interact_policy, target.interact_policy):
		return false
		
	return true


func _use_skill(entity: Entity, target: Entity = null) -> void:
	start_cooldown()
	entity.play_animation(animation, &"melee")
	AudioManager.play_sfx(sfx)
	if await entity.y_wait(delay) or not target or not target.state & Entity.State.MELEE:
		compensate_cooldown()
		return
	
	if search_at_target_position_enabled:
		influence.take_influence(entity, target, target.global_position)
	else:
		influence.take_influence(entity, target, entity.global_position)
	
	if await entity.y_wait_animation(animation):
		return
		
	entity.play_animation(entity.idle_animation, &"idle")