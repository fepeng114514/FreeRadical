@tool
extends SearchSkill
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
## 搜索资源，用于搜索目标，如果不设置该资源，实体将会生成到释放者的位置。
@export var searcher: Searcher = null:
	set(v): 
		searcher = v
		U.resource_redraw_setter(self, searcher)


func _ready() -> void:
	if Engine.is_editor_hint():
		U.connect_resource_changed(spawn_offsets, queue_redraw)
		U.connect_resource_changed(searcher, queue_redraw)


func _draw() -> void:
	if Engine.is_editor_hint():
		if searcher:
			searcher.draw(self, position)

		OffsetGroup.draw_offset_group(self, spawn_offsets)


func _use_skill(e: Entity, target: Entity = null) -> void:
	if searcher:
		target = searcher.search_target(get_search_center(e), e)
		if not target:
			return
			
		e.look_point = target.global_position
	start_cooldown()
		
	e.play_animation(animation)
	AudioMgr.play_sfx(sfx)
	if await e.y_wait(delay):
		compensate_cooldown()
		return

	if searcher and not target:
		target = searcher.search_target(get_search_center(e), e)
		if not target:
			compensate_cooldown()
			return

	var e_global_pos: Vector2 = e.global_position
	var spawn_pos: Vector2 = target.global_position if searcher else e_global_pos
	if spawn_offsets:
		var spawn_offset: Vector2 = spawn_offsets.get_offset_for_point(e_global_pos, e.look_point)
		spawn_pos += spawn_offset

	EntityMgr.create_entities(spawns, 
		func(new_e: Entity) -> void:
			new_e.set_pos(spawn_pos)
			new_e.source_id = e.id
	)

	await e.y_wait_animation(animation)
