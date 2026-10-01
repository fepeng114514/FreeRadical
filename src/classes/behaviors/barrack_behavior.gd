extends Behavior
class_name BarrackBehavior
## 兵营行为。
##
## BarrackBehavior 负责处理拥有 [BarrackComponent] 兵营组件的实体生成士兵。


func _on_insert(barrack: Entity) -> bool:
	var barrack_c: BarrackComponent = barrack.get_node_or_null(Constants.CN_BARRACK)
	if not barrack_c:
		return true
	
	_spawn_all_soldiers(barrack, barrack_c)
		
	return true


func _on_remove(barrack: Entity) -> bool:
	var barrack_c: BarrackComponent = barrack.get_node_or_null(Constants.CN_BARRACK)
	if not barrack_c:
		return true
	
	var soldier_list: Array[Entity] = barrack_c.soldier_list
	for _soldier_idx: int in soldier_list.size():
		EntityManager.queue_remove_entity(soldier_list[0])

	return true


func _on_update(barrack: Entity) -> bool:
	var barrack_c: BarrackComponent = barrack.get_node_or_null(Constants.CN_BARRACK)
	if not barrack_c:
		return false

	if barrack_c.config.disabled:
		return false
	
	# 根据重生时间生成士兵
	if TimeManager.has_elapsed(barrack_c.time_stamp, barrack_c.config.spawn_interval):
		_spawn_by_time(barrack, barrack_c)
		return true
		
	var soldier_list_size: int = barrack_c.soldier_list.size()

	# 士兵数发生变化重新整队
	if barrack_c.last_soldier_count != soldier_list_size:
		barrack_c.set_rally_center_global_position(barrack_c.config.rally_center_global_position, false, false)
		barrack_c.last_soldier_count = soldier_list_size
	return false


## 生成士兵。
func _spawn_soldier(
		barrack: Entity, barrack_c: BarrackComponent
	) -> Entity:

	var soldier: Entity = EntityManager.create_entity(barrack_c.config.soldier_scene)
	soldier.source_id = barrack.id
	soldier.source_type = Entity.SourceType.BARRACK_SOLDIER
	soldier.tree_exiting.connect(_on_soldier_removed.bind(soldier, barrack_c))

	var barrack_global_position: Vector2 = barrack.global_position
	var soldier_global_position: Vector2 = barrack_global_position
	if barrack_c.config.spawn_offsets:
		var offset: Vector2 = barrack_c.config.spawn_offsets.get_offset_toward_point(
			barrack_global_position, barrack.facing_global_position
		)
		soldier_global_position += offset
	soldier.global_position = soldier_global_position

	barrack_c.soldier_list.append(soldier)
	EntityManager.queue_insert_entity(soldier)
	
	return soldier


func _on_soldier_removed(soldier: Entity, barrack_c: BarrackComponent) -> void:
	barrack_c.soldier_list.erase(soldier)


## 根据重生时间生成士兵。
func _spawn_by_time(barrack: Entity, barrack_c: BarrackComponent) -> void:
	barrack_c.time_stamp = TimeManager.tick_time_stamp

	if barrack_c.soldier_list.size() >= barrack_c.config.max_soldier_count:
		return
		
	barrack.play_animation(barrack_c.config.animation)
	AudioManager.play_sfx(barrack_c.config.sfx)
	if await barrack.y_wait(barrack_c.config.delay):
		return

	_spawn_soldier(barrack, barrack_c)
	
	barrack_c.set_rally_center_global_position(barrack_c.config.rally_center_global_position, false, false)
	barrack_c.last_soldier_count = barrack_c.soldier_list.size()
	barrack.y_wait_animation(barrack_c.config.animation)


## 生成所有士兵。
func _spawn_all_soldiers(barrack: Entity, barrack_c: BarrackComponent) -> void:
	var soldier_list: Array[Entity] = barrack_c.soldier_list
	var last_soldier_list: Array[Entity] = barrack_c.last_soldier_list
	var has_replace_all: bool = true

	# 先替换存活的士兵
	if last_soldier_list:
		var last_soldier_list_size: int = last_soldier_list.size()
		
		for soldier_index: int in barrack_c.config.max_soldier_count:
			if soldier_index >= last_soldier_list_size:
				has_replace_all = false
				break
				
			var soldier: Entity = _spawn_soldier(barrack, barrack_c)
			var last_soldier: Entity = last_soldier_list[soldier_index]

			soldier.global_position = last_soldier.global_position

			if last_soldier.state & Entity.State.RALLY:
				continue

			var last_melee_c: MeleeComponent = last_soldier.get_node_or_null(Constants.CN_MELEE)
			if last_melee_c:
				var melee_c: MeleeComponent = soldier.get_node_or_null(Constants.CN_MELEE)
				if melee_c:
					soldier.state = Entity.State.MELEE

					if melee_c.is_blocker:
						for blocked_id: int in last_melee_c.blocked_id_list:
							melee_c.blocker_bind_melee_relations(soldier.id, blocked_id)
					else:
						for blocker_id: int in last_melee_c.blocker_id_list:
							melee_c.blocked_bind_melee_relations(blocker_id, soldier.id)
		
		barrack_c.last_soldier_count = soldier_list.size()
		barrack_c.set_rally_center_global_position(barrack_c.config.rally_center_global_position, false)
	else:
		has_replace_all = false

	if not has_replace_all:
		barrack.play_animation(barrack_c.config.animation)
		AudioManager.play_sfx(barrack_c.config.sfx)
		if await barrack.y_wait(barrack_c.config.delay):
			return

		var max_soldier_count: int = barrack_c.config.max_soldier_count

		# 生成新的士兵
		for soldier_index: int in range(soldier_list.size(), max_soldier_count):
			_spawn_soldier(barrack, barrack_c)

		barrack_c.set_rally_center_global_position(barrack_c.config.rally_center_global_position, false)
		barrack_c.last_soldier_count = soldier_list.size()
		
		barrack.y_wait_animation(barrack_c.config.animation)
