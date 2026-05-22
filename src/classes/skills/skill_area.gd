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
		
		
func _do_skill(e: Entity, skill_idx: int, target: Entity = null) -> void:
	if not target:
		var targets: Array[Entity] = search.search_targets(e, e.global_position)
		if not targets:
			return

		target = targets[0]
	e.look_point = target.global_position
	start_cooldown(e, skill_idx)

	e.play_animation_by_look(animation)
	AudioMgr.play_sfx(sfx)
	if await e.y_wait(delay) or not target:
		compensate_cooldown(e, skill_idx)
		return

	if search_target_pos:
		influence.take_influence(e, target, target.global_position)
	else:
		influence.take_influence(e, target, e.global_position)

	await e.y_wait_animation(animation)
