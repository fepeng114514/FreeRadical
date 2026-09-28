@tool
extends SearchSkill
class_name SpawnSkill
## 生成实体技能节点。
##
## SpawnSkill 会生成一个实体。


@export var config: SpawnSkillNodeConfig = null:
	set(v):
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()

## 生成的实体场景名称数组。
@export_file("*.tscn") var spawns: PackedStringArray
## 生成的实体初始位置偏移组。
@export var spawn_offsets: OffsetGroup = null


func _draw() -> void:
	super()
	
	if DebugManager.draw_offset_enabled:
		if spawn_offsets:
			spawn_offsets.draw_offset_group(self)


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

	EntityManager.create_entities(spawns, 
		func(new_entity: Entity) -> void:
			new_entity.set_global_position_with_components(spawn_global_position)
			new_entity.source_id = entity.id
	)

	await entity.y_wait_animation(animation)