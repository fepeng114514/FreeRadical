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

	var baq: BehaviorActionQueue = e.behavior_action_queue
	baq.wait_anim(animation)
	
	for _i: int in loop_count:
		baq.call_fn(
			func() -> void:
				if not U.is_valid_entity(target):
					compensate_cooldown(e, skill_idx)
					baq.clear()
					return

				e.look_point = target.global_position
				e.play_animation_by_look(loop_animation)
				AudioMgr.play_sfx(loop_sfx)
		)
		baq.wait(delay)
		baq.call_fn(func(): spawn_bullets(e, target))
		baq.wait_anim(loop_animation)

	baq.wait_anim(loop_animation)
	baq.call_fn(
		func() -> void:
			e.play_animation_by_look(end_animation)
			AudioMgr.play_sfx(end_sfx)
	)
	baq.wait_anim(end_animation)