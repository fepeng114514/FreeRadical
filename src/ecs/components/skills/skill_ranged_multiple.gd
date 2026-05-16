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


func _do_skill(e: Entity) -> void:
	var target: Entity = search_target(e, self)
	if not target:
		return

	e.look_point = target.global_position

	e.play_animation_by_look(animation, "ranged")
	AudioMgr.play_sfx(sfx)
	await e.wait_animation(animation)

	if not target:
		return

	for i: int in loop_count:
		if not U.is_valid_entity(target):
			break
			
		e.look_point = target.global_position
		e.play_animation_by_look(loop_animation)

		AudioMgr.play_sfx(loop_sfx)
		await e.y_wait(delay)

		spawn_bullets(e, target)
		await e.wait_animation(loop_animation)

	await e.wait_animation(loop_animation)

	e.play_animation_by_look(end_animation)
	AudioMgr.play_sfx(end_sfx)
	await e.wait_animation(end_animation)
