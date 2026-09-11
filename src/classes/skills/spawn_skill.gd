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
		Utils.resource_redraw_setter(self, spawn_offsets)
## 搜索资源，用于搜索目标，如果不设置该资源，实体将会生成到释放者的位置。
@export var searcher: Searcher = null:
	set(v): 
		searcher = v
		Utils.resource_redraw_setter(self, searcher)


func _ready() -> void:
	if Engine.is_editor_hint():
		Utils.connect_resource_changed(spawn_offsets, queue_redraw)
		Utils.connect_resource_changed(searcher, queue_redraw)


func _draw() -> void:
	if Engine.is_editor_hint():
		if searcher:
			searcher.draw(self, position)

		OffsetGroup.draw_offset_group(self, spawn_offsets)


func _use_skill(entity: Entity, target: Entity = null) -> void:
	if searcher:
		target = searcher.search_target(get_search_global_position(entity), entity)
		if not target:
			return
			
		entity.facing_global_position = target.global_position
	start_cooldown()
		
	entity.play_animation(animation)
	AudioManager.play_sfx(sfx)
	if await entity.y_wait(delay):
		compensate_cooldown()
		return

	if searcher and not target:
		target = searcher.search_target(get_search_global_position(entity), entity)
		if not target:
			compensate_cooldown()
			return

	var entity_global_position: Vector2 = entity.global_position
	var spawn_global_position: Vector2 = target.global_position if searcher else entity_global_position
	if spawn_offsets:
		var spawn_offset: Vector2 = spawn_offsets.get_offset_toward_point(entity_global_position, entity.facing_global_position)
		spawn_global_position += spawn_offset

	ECSEntityManager.create_entities(spawns, 
		func(new_entity: Entity) -> void:
			new_entity.set_global_position_with_components(spawn_global_position)
			new_entity.source_id = entity.id
	)

	await entity.y_wait_animation(animation)
