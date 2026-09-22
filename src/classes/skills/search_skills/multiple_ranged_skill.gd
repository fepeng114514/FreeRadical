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

## 循环次数。
@export var loop_count: int = 1
## 循环动画组。
@export var loop_animation: AnimationGroup = null
## 结束动画组。
@export var end_animation: AnimationGroup = null
## 攻击音效组。
@export var loop_sfx: AudioGroup = null
## 攻击音效组。
@export var end_sfx: AudioGroup = null


func _use_skill(entity: Entity, target: Entity = null) -> void:
	target = searcher.search_target(get_search_global_position(entity), entity)
	if not target:
		return
	
	entity.facing_global_position = target.global_position
	start_cooldown()
	
	entity.play_animation(animation, &"ranged")
	AudioManager.play_sfx(sfx)
	if await entity.y_wait_animation(animation):
		compensate_cooldown()
		return

	for loop_index: int in loop_count:
		if not target:
			target = searcher.search_target(get_search_global_position(entity), entity)
			if not target:
				compensate_cooldown()
				return
				
		if not target:
			break
			
		entity.facing_global_position = target.global_position
		entity.play_animation(loop_animation)

		AudioManager.play_sfx(loop_sfx)
		if await entity.y_wait(delay):
			return

		_spawn_bullets(entity, target)
		if await entity.y_wait_animation(loop_animation):
			return

	if await entity.y_wait_animation(loop_animation):
		return

	entity.play_animation(end_animation)
	AudioManager.play_sfx(end_sfx)
	await entity.y_wait_animation(end_animation)


