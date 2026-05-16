@tool
extends Skill
class_name SkillSpawn
## 生成实体技能节点


@export var spawns: Array[StringName] = []
@export var spawn_offsets: OffsetGroup = null:
	set(value):
		spawn_offsets = value
		if Engine.is_editor_hint():
			U.connect_offset_group_changed(spawn_offsets, _on_spawn_offsets_changed)
		queue_redraw()

@export_group("Search")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var search_enable: bool = true
@export var search_mode: C.SearchMode = C.SearchMode.ENEMY_MAX_PROGRESS
## 最小搜索距离
@export var min_range: float = 0:
	set(value):
		min_range = value
		queue_redraw()
## 最大搜索距离
@export var max_range: float = 300:
	set(value):
		max_range = value
		queue_redraw()
## 技能标识
@export var flags: C.Flag = C.Flag.NONE
## 不可搜索的目标的标识
@export var bans: int = 0
## 可搜索的目标的场景名称列表
@export var whitelist := PackedStringArray()
## 不可搜索的目标的场景名称列表
@export var blacklist := PackedStringArray()


func _ready() -> void:
	if Engine.is_editor_hint():
		U.connect_offset_group_changed(spawn_offsets, _on_spawn_offsets_changed)


func _on_spawn_offsets_changed() -> void:
	queue_redraw()


func _draw() -> void:
	if Engine.is_editor_hint():
		U.draw_offset_group(self, spawn_offsets)
		U.draw_range_circle(self, position, min_range, max_range)


func _do_skill(e: Entity) -> void:
	var target: Entity = null
	if search_enable:
		target = search_target(e, self)
		if not target:
			return

		e.look_point = target.global_position

	e.play_animation_by_look(animation, "ranged")
	AudioMgr.play_sfx(sfx)
	await e.y_wait(delay)

	if search_enable and not target:
		return

	var e_global_pos: Vector2 = e.global_position
	var spawn_pos: Vector2 = e_global_pos if not search_enable else target.global_position
	if spawn_offsets:
		var spawn_offset: Vector2 = spawn_offsets.get_offset_for_point(e_global_pos, e.look_point)
		spawn_pos += spawn_offset

	EntityMgr.create_entities(spawns, 
		func(new_e: Entity) -> void:
			new_e.set_pos(spawn_pos)
			new_e.source_id = e.id
	)

	await e.wait_animation(animation)
