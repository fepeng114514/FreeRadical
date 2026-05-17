@tool
extends Skill
class_name SkillSpawn
## 生成实体技能节点


@export var spawns: Array[StringName] = []
@export var spawn_offsets: OffsetGroup = null:
	set(value):
		spawn_offsets = value
		if Engine.is_editor_hint():
			U.connect_resource_changed(spawn_offsets, queue_redraw)
			queue_redraw()
@export var search: SearchResource = null:
	set(value):
		search = value
		if Engine.is_editor_hint():
			U.connect_resource_changed(search, queue_redraw)
			queue_redraw()
@export var search_target_pos: bool = false


func _ready() -> void:
	if Engine.is_editor_hint():
		U.connect_resource_changed(spawn_offsets, queue_redraw)
		U.connect_resource_changed(search, queue_redraw)


func _draw() -> void:
	if Engine.is_editor_hint():
		if search:
			search.draw(self, position)

		U.draw_offset_group(self, spawn_offsets)


func _do_skill(e: Entity) -> void:
	var target: Entity = null
	if search:
		var targets: Array[Entity] = search.search_targets(e, e.global_position)
		if not targets:
			return
			
		target = targets[0]
		e.look_point = target.global_position

	e.play_animation_by_look(animation, "ranged")
	AudioMgr.play_sfx(sfx)
	await e.y_wait(delay)

	if search and not target:
		return

	var e_global_pos: Vector2 = e.global_position
	var spawn_pos: Vector2 = target.global_position if search_target_pos else e_global_pos
	if spawn_offsets:
		var spawn_offset: Vector2 = spawn_offsets.get_offset_for_point(e_global_pos, e.look_point)
		spawn_pos += spawn_offset

	EntityMgr.create_entities(spawns, 
		func(new_e: Entity) -> void:
			new_e.set_pos(spawn_pos)
			new_e.source_id = e.id
	)

	await e.wait_animation(animation)
