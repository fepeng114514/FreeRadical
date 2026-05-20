@tool
extends Skill
class_name SkillArea
## 范围技能节点


@export var search: SearchResource = null:
	set(value):
		search = value
		if Engine.is_editor_hint():
			U.connect_resource_changed(search, queue_redraw)
			queue_redraw()
@export var influence: InfluenceResource = null:
	set(value):
		influence = value
		if Engine.is_editor_hint():
			U.connect_resource_changed(influence, queue_redraw)
			queue_redraw()
@export var search_target_pos: bool = false


func _ready() -> void:
	if Engine.is_editor_hint():
		U.connect_resource_changed(search, queue_redraw)
		U.connect_resource_changed(influence, queue_redraw)


func _draw() -> void:
	if Engine.is_editor_hint():
		if search:
			search.draw(self, position)
		if influence:
			influence.draw(self, position)
		
		
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
	baq.wait(delay)
	baq.call_fn(
		func() -> void:
			if not U.is_valid_entity(target):
				compensate_cooldown(e, skill_idx)
				baq.clear()
				return

			if search_target_pos:
				influence.take_influence(e, target, target.global_position)
			else:
				influence.take_influence(e, target, e.global_position)
	)
	baq.wait_anim(animation)
