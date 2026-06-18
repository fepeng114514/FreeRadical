@tool
extends Skill
class_name SkillSpawn
## 生成实体技能节点。
##
## SkillSpawn 会生成一个实体。


## 生成的实体场景名称数组。
@export var spawns: Array[PackedScene] = []
## 生成的实体初始位置偏移组。
@export var spawn_offsets: OffsetGroup = null:
	set(v): 
		spawn_offsets = v
		U.resource_redraw_setter(self, spawn_offsets)
## 搜索资源。
@export var search: SearchResource = null:
	set(v): 
		search = v
		U.resource_redraw_setter(self, search)
## 是否搜索第一个目标位置，如果为 false 则以释放者的位置为中心造成影响，而非第一个目标的位置。
@export var search_target_pos: bool = false


func _ready() -> void:
	if Engine.is_editor_hint():
		U.connect_resource_changed(spawn_offsets, queue_redraw)
		U.connect_resource_changed(search, queue_redraw)


func _draw() -> void:
	if Engine.is_editor_hint():
		if search:
			search.draw(self, position)

		OffsetGroup.draw_offset_group(self, spawn_offsets)


func _do_skill(e: Entity, skill_idx: int, target: Entity = null) -> void:
	if not target and search:
		target = search.search_target(e, e.global_position)
		if not target:
			return
			
	if target:
		e.look_point = target.global_position
	start_cooldown(e, skill_idx)
		
	e.play_animation(animation)
	AudioMgr.play_sfx(sfx)
	if await e.y_wait(delay) or search and not target:
		compensate_cooldown(e, skill_idx)
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
