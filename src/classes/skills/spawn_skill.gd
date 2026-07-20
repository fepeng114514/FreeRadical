@tool
extends Skill
class_name SpawnSkill
## 生成实体技能节点。
##
## SpawnSkill 会生成一个实体。


## 生成的实体场景名称数组。
@export_file("*.tscn") var spawns := PackedStringArray()
## 生成的实体初始位置偏移组。
@export var spawn_offsets: OffsetGroup = null:
	set(v): 
		spawn_offsets = v
		U.resource_redraw_setter(self, spawn_offsets)
## 搜索资源，用于搜索目标，如果设置了该资源，实体将会生成到搜索到的第一个目标的位置。
@export var searcher: Searcher = null:
	set(v): 
		searcher = v
		U.resource_redraw_setter(self, searcher)
## 是否搜索第一个目标位置，如果为 false 则以释放者的位置为中心造成影响，而非第一个目标的位置。
@export var search_target_pos: bool = false


func _ready() -> void:
	if Engine.is_editor_hint():
		U.connect_resource_changed(spawn_offsets, queue_redraw)
		U.connect_resource_changed(searcher, queue_redraw)


func _draw() -> void:
	if Engine.is_editor_hint():
		if searcher:
			searcher.draw(self, position)

		OffsetGroup.draw_offset_group(self, spawn_offsets)


func _do_skill(e: Entity, target: Entity = null) -> void:
	if not target and searcher:
		target = searcher.search_target(e.global_position, e)
		if not target:
			return
			
	if target:
		e.look_point = target.global_position
	start_cooldown(e)
		
	e.play_animation(animation)
	AudioMgr.play_sfx(sfx)
	if await e.y_wait(delay):
		compensate_cooldown(e)
		return

	if searcher and not target:
		target = searcher.search_target(e.global_position, e)
		if not target:
			compensate_cooldown(e)
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

	await e.y_wait_animation(animation)
