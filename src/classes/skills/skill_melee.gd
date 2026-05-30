@tool
extends Skill
class_name SkillMelee
## 近战技能节点
##
## 用于 [MeleeComponent]


## 伤害/治疗/范围伤害 统一资源
@export var influence: InfluenceResource = null:
	set(v): 
		influence = v
		if Engine.is_editor_hint():
			U.connect_resource_changed(influence, queue_redraw)
			queue_redraw()
@export var search_target_pos: bool = false
@export var interact_policy: InteractPolicy = null


func _ready() -> void:
	U.connect_resource_changed(influence, queue_redraw)


func _draw() -> void:
	if Engine.is_editor_hint():
		if influence:
			influence.draw(self, position)


func check_ready(e: Entity, target: Entity = null) -> bool:
	if not super(e, target):
		return false
		
	if not InteractPolicy.is_allowed_entity(e, target, interact_policy, target.interact_policy):
		return false
		
	return true


func _do_skill(e: Entity, skill_idx: int, target: Entity = null) -> void:
	start_cooldown(e, skill_idx)
	e.play_animation_by_look(animation, &"melee")
	if await e.y_wait(delay) or not target:
		compensate_cooldown(e, skill_idx)
		return
	
	if search_target_pos:
		influence.take_influence(e, target, target.global_position, Skill.Type.MELEE)
	else:
		influence.take_influence(e, target, e.global_position, Skill.Type.MELEE)
	
	if await e.y_wait_animation(animation):
		return
		
	e.play_animation_by_look(e.idle_animation, &"idle")
