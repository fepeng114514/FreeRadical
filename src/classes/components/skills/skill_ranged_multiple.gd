@tool
extends SkillRanged
class_name SkillRangedMultiple
## 多次远程技能节点


## 循环次数
@export var loop_count: int = 1
## 循环动画
@export var loop_animation: AnimationGroup = null
## 结束动画
@export var end_animation: AnimationGroup = null
## 攻击音效
@export var loop_sfx: AudioGroup = null
## 攻击音效
@export var end_sfx: AudioGroup = null


func _do_skill(e: Entity, skill_idx: int) -> void:
	var targets: Array[Entity] = search.search_targets(e, e.global_position)
	if not targets:
		return
		
	var target: Entity = targets[0]
	e.look_point = target.global_position
	start_cooldown(e, skill_idx)
	
	e.play_animation_by_look(animation, "ranged")
	AudioMgr.play_sfx(sfx)
	if await e.y_wait_animation(animation) or not target:
		compensate_cooldown(e, skill_idx)
		return

	for i: int in loop_count:
		if not U.is_valid_entity(target):
			break
			
		e.look_point = target.global_position
		e.play_animation_by_look(loop_animation)

		AudioMgr.play_sfx(loop_sfx)
		if await e.y_wait(delay):
			return

		spawn_bullets(e, target)
		if await e.y_wait_animation(loop_animation):
			return

	if await e.y_wait_animation(loop_animation):
		return

	e.play_animation_by_look(end_animation)
	AudioMgr.play_sfx(end_sfx)
	await e.y_wait_animation(end_animation)
