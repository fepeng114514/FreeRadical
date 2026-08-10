@tool
extends RangedSkill
class_name MultipleRangedSkill
## 多次远程技能节点。
##
## MultipleRangedSkill 与 [RangedSkill] 相似，但是可以连续攻击多次。

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


func _use_skill(e: Entity, target: Entity = null) -> void:
	target = searcher.search_target(get_search_center(e), e)
	if not target:
		return
	
	e.look_point = target.global_position
	start_cooldown()
	
	e.play_animation(animation, &"ranged")
	AudioMgr.play_sfx(sfx)
	if await e.y_wait_animation(animation):
		compensate_cooldown()
		return

	for i: int in loop_count:
		if not target:
			target = searcher.search_target(get_search_center(e), e)
			if not target:
				compensate_cooldown()
				return
				
		if not U.is_valid_entity(target):
			break
			
		e.look_point = target.global_position
		e.play_animation(loop_animation)

		AudioMgr.play_sfx(loop_sfx)
		if await e.y_wait(delay):
			return

		_spawn_bullets(e, target)
		if await e.y_wait_animation(loop_animation):
			return

	if await e.y_wait_animation(loop_animation):
		return

	e.play_animation(end_animation)
	AudioMgr.play_sfx(end_sfx)
	await e.y_wait_animation(end_animation)
