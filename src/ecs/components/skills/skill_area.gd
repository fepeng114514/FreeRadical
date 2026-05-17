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
@export var search_target_pos: bool = false
@export var influence: InfluenceResource = null:
	set(value):
		influence = value
		if Engine.is_editor_hint():
			U.connect_resource_changed(influence, queue_redraw)
			queue_redraw()


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
		
		
func _do_skill(e: Entity) -> void:
	var targets: Array[Entity] = search.search_targets(e, e.global_position)
	if not targets:
		return

	var target: Entity = targets[0]
	e.look_point = target.global_position

	e.play_animation_by_look(animation, "ranged")
	AudioMgr.play_sfx(sfx)
	await e.y_wait(delay)

	if not target:
		return

	if search_target_pos:
		influence.take(e, target, target.global_position)
	else:
		influence.take(e, target, e.global_position)

	await e.wait_animation(animation)
