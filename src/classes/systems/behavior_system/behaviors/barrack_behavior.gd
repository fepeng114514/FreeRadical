extends Behavior
class_name BarrackBehavior
## 兵营行为。
##
## [BarrackBehavior] 负责处理拥有 [BarrackComponent] 的实体。


func _on_insert(barrack: Entity) -> bool:
	var barrack_c: BarrackComponent = barrack.get_node_or_null(Constants.BARRACK_COMPONENT_NODE_PATH)
	if not barrack_c:
		return true
	
	var barrack_record: BarrackRecord = barrack.get_node_or_null(Constants.BARRACK_RECORD_NODE_PATH)
	if not barrack_record.rally_center_global_position:
		barrack_record.rally_center_global_position = barrack.to_global(barrack_record.default_rally_center_position)
	
	_spawn_all_soldiers(barrack, barrack_c, barrack_record)

	return true


func _on_remove(barrack: Entity) -> bool:
	var barrack_c: BarrackComponent = barrack.get_node_or_null(Constants.BARRACK_COMPONENT_NODE_PATH)
	if not barrack_c:
		return true
	
	var barrack_record: BarrackRecord = barrack.get_node_or_null(Constants.BARRACK_RECORD_NODE_PATH)
	var soldier_list: Array[Entity] = barrack_record.soldier_list
	for soldier_idx: int in soldier_list.size():
		EntityManager.queue_remove_entity(soldier_list[soldier_idx])

	return true


func _on_update(barrack: Entity) -> bool:
	var barrack_c: BarrackComponent = barrack.get_node_or_null(Constants.BARRACK_COMPONENT_NODE_PATH)
	if not barrack_c:
		return false

	if barrack_c.config.disabled:
		return false
	
	var barrack_record: BarrackRecord = barrack.get_node_or_null(Constants.BARRACK_RECORD_NODE_PATH)
	# 根据重生时间生成士兵
	if TimeManager.has_elapsed(barrack_c.timestamp, barrack_c.config.spawn_interval):
		_spawn_by_time(barrack, barrack_c, barrack_record)
		return true
		
	var soldier_list_size: int = barrack_record.soldier_list.size()

	# 士兵数发生变化重新整队
	if barrack_c.last_soldier_count != soldier_list_size:
		barrack_c.last_soldier_count = soldier_list_size
		barrack_c.set_rally_center_global_position(barrack_record.rally_center_global_position, false, false)
	return false


## 创建士兵。
func _create_soldier(
		barrack: Entity, barrack_c: BarrackComponent, barrack_record: BarrackRecord
	) -> Entity:
	var barrack_c_config: BarrackComponentNodeConfig = barrack_c.config
	var soldier: Entity = EntityManager.create_entity(barrack_c_config.soldier_scene)
	soldier.source_id = barrack.id
	soldier.source_type = Entity.SourceType.BARRACK_SOLDIER
	soldier.entity_removing.connect(_on_soldier_removing.bind(soldier, barrack_c, barrack_record))

	var barrack_global_position: Vector2 = barrack.global_position
	var soldier_global_position: Vector2 = barrack_global_position
	if barrack_c_config.spawn_offsets:
		var offset: Vector2 = barrack_c_config.spawn_offsets.get_offset_toward_point(
			barrack_global_position, barrack.facing_global_position
		)
		soldier_global_position += offset
	soldier.global_position = soldier_global_position

	EntityManager.queue_insert_entity(soldier)
	
	return soldier


## 根据重生时间生成士兵。
func _spawn_by_time(barrack: Entity, barrack_c: BarrackComponent, barrack_record: BarrackRecord) -> void:
	barrack_c.timestamp = TimeManager.tick_timestamp

	var barrack_c_config: BarrackComponentNodeConfig = barrack_c.config
	if barrack_record.soldier_list.size() >= barrack_c_config.max_soldier_count:
		return
		
	AudioManager.play_sfx(barrack_c_config.spawn_sfx)
	var animated_sprite_c: AnimatedSpriteComponent = barrack.get_node_or_null(Constants.ANIMATED_SPRITE_COMPONENT_NODE_PATH)
	var spawn_animation: AnimationGroup = animated_sprite_c.config.spawn_animation
	if spawn_animation:
		animated_sprite_c.play_animation(barrack, spawn_animation)
	if await barrack.y_wait(barrack_c_config.spawn_delay):
		return

	var soldier: Entity = _create_soldier(barrack, barrack_c, barrack_record)
	barrack_record.soldier_list.append(soldier)
	
	if spawn_animation:
		animated_sprite_c.y_wait_animation(barrack, spawn_animation)


## 生成所有士兵。
func _spawn_all_soldiers(barrack: Entity, barrack_c: BarrackComponent, barrack_record: BarrackRecord) -> void:
	var barrack_c_config: BarrackComponentNodeConfig = barrack_c.config
	var old_soldier_list: Array[Entity] = barrack_record.soldier_list
	var new_soldier_list: Array[Entity] = []
	var old_soldier_list_size: int = old_soldier_list.size()

	# 先替换存活的士兵
	if old_soldier_list:
		for soldier_index: int in old_soldier_list_size:
			var soldier: Entity = _create_soldier(barrack, barrack_c, barrack_record)
			var old_soldier: Entity = old_soldier_list[soldier_index]
			new_soldier_list.append(soldier)

			soldier.global_position = old_soldier.global_position
			soldier.facing_global_position = old_soldier.facing_global_position

			if old_soldier.state & Entity.State.RALLY:
				continue

			var old_rally_c: RallyComponent = old_soldier.get_node_or_null(Constants.RALLY_COMPONENT_NODE_PATH)
			if old_rally_c:
				var rally_c: RallyComponent = soldier.get_node_or_null(Constants.RALLY_COMPONENT_NODE_PATH)
				if rally_c:
					rally_c.rally_center_global_position = old_rally_c.rally_center_global_position

			var old_melee_c: MeleeComponent = old_soldier.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
			if old_melee_c:
				var melee_c: MeleeComponent = soldier.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
				if melee_c:
					melee_c.is_blocker = old_melee_c.is_blocker
					soldier.state = Entity.State.MELEE

					if melee_c.is_blocker:
						for blocked_id: int in old_melee_c.blocked_id_list:
							melee_c.blocker_bind_melee_relations(soldier.id, blocked_id)
					else:
						for blocker_id: int in old_melee_c.blocker_id_list:
							melee_c.blocked_bind_melee_relations(blocker_id, soldier.id)
		
		barrack_c.set_rally_center_global_position(barrack_record.rally_center_global_position, false)
	
	barrack_record.soldier_list = new_soldier_list

	if old_soldier_list_size < barrack_c_config.max_soldier_count:
		AudioManager.play_sfx(barrack_c_config.spawn_sfx)
		var animated_sprite_c: AnimatedSpriteComponent = barrack.get_node_or_null(Constants.ANIMATED_SPRITE_COMPONENT_NODE_PATH)
		var spawn_animation: AnimationGroup = barrack_c_config.spawn_animation
		if spawn_animation:
			animated_sprite_c.play_animation(barrack, spawn_animation)
		if await barrack.y_wait(barrack_c_config.spawn_delay):
			return

		var max_soldier_count: int = barrack_c_config.max_soldier_count
		for soldier_index: int in range(old_soldier_list_size, max_soldier_count):
			var soldier: Entity = _create_soldier(barrack, barrack_c, barrack_record)
			new_soldier_list.append(soldier)

		barrack_c.set_rally_center_global_position(barrack_record.rally_center_global_position, false)
		
		if spawn_animation:
			animated_sprite_c.y_wait_animation(barrack, spawn_animation)


func _on_soldier_removing(soldier: Entity, _barrack_c: BarrackComponent, barrack_record: BarrackRecord) -> void:
	barrack_record.soldier_list.erase(soldier)
