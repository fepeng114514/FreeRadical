@tool
extends Skill
class_name MeleeSkill
## 近战技能节点。
##
## MeleeSkill 与 [AreaSkill] 唯一区别的就是没有搜索目标这一步，需要被传入目标。[br]
## 主要用于 [MeleeComponent] 与 [DodgeComponent] 进行近战技能。


## 影响资源，用于对目标造成伤害或治愈目标。
@export var influence: Influence = null:
	set(v): 
		influence = v
		U.resource_redraw_setter(self, influence)
## 是否搜索第一个目标位置，如果为 false 则以释放者的位置为中心造成影响，而非第一个目标的位置。
@export var search_target_pos: bool = false
## 交互策略。
@export var interact_policy: InteractPolicy = null


func _ready() -> void:
	if Engine.is_editor_hint():
		U.connect_resource_changed(influence, queue_redraw)


func _draw() -> void:
	if Engine.is_editor_hint():
		if influence:
			influence.draw(self, position)


func can_do(e: Entity, target: Entity = null) -> bool:
	if not super(e, target):
		return false
		
	if not InteractPolicy.is_allowed_target(e, target, interact_policy, target.interact_policy):
		return false
		
	return true


func _use_skill(e: Entity, target: Entity = null) -> void:
	start_cooldown(e)
	e.play_animation(animation, &"melee")
	AudioMgr.play_sfx(sfx)
	if await e.y_wait(delay) or not target:
		compensate_cooldown(e)
		return
	
	if search_target_pos:
		influence.take_influence(e, target, target.global_position)
	else:
		influence.take_influence(e, target, e.global_position)
	
	if await e.y_wait_animation(animation):
		return
		
	e.play_animation(e.idle_animation, &"idle")
