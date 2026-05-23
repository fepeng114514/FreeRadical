extends Behavior
class_name BarrackBehavior
## 兵营行为系统
##
## 处理拥有 [BarrackComponent] 兵营组件的实体生成士兵


func _on_insert(e: Entity) -> bool:
	var barrack_c: BarrackComponent = e.get_node_or_null(C.CN_BARRACK)
	if not barrack_c:
		return true
	
	_spawn_all_soldiers(e, barrack_c)
		
	return true


func _on_remove(e: Entity) -> bool:
	var barrack_c: BarrackComponent = e.get_node_or_null(C.CN_BARRACK)
	if not barrack_c:
		return true
	
	var soldier_group: EntityGroup = barrack_c.soldier_group
	for soldier: Entity in soldier_group.get_children():
		soldier.remove_entity()
		
	return true


func _on_update(e: Entity) -> bool:
	var barrack_c: BarrackComponent = e.get_node_or_null(C.CN_BARRACK)
	if not barrack_c:
		return false

	if barrack_c.disabled:
		return false
		
	var soldier_group: EntityGroup = barrack_c.soldier_group
	
	# 根据重生时间生成士兵
	if TimeMgr.is_ready_time(barrack_c.ts, barrack_c.spawn_time):
		_spawn_by_time(e, barrack_c)
		return true
		
	var soldier_count: int = soldier_group.get_child_count()

	# 士兵数发生变化重新整队
	if barrack_c.last_soldier_count != soldier_count:
		barrack_c.new_rally_center_position(barrack_c.rally_center_position, false, false)
	
	barrack_c.last_soldier_count = soldier_count
	return false


func _spawn_soldier(
		barrack: Entity, barrack_c: BarrackComponent, soldier_group: EntityGroup
	) -> Entity:
	var soldier: Entity = EntityMgr.create_entity(barrack_c.soldier)
	var barrack_global_pos: Vector2 = barrack.global_position
	var soldier_global_pos: Vector2 = barrack_global_pos
	if barrack_c.spawn_offsets:
		var offset: Vector2 = barrack_c.spawn_offsets.get_offset_for_point(
			barrack_global_pos, barrack.look_point
		)
		soldier_global_pos += offset
	soldier.global_position = soldier_global_pos
	if not barrack._on_barrack_respawn(soldier, barrack_c):
		return soldier
	
	soldier_group.add_child(soldier)
	soldier.insert_entity()
	
	return soldier


func _spawn_by_time(e: Entity, barrack_c: BarrackComponent) -> void:
	var soldier_group: EntityGroup = barrack_c.soldier_group
	var max_soldier_count: int = barrack_c.max_soldier_count
	var soldier_count: int = soldier_group.get_child_count()
	
	barrack_c.ts = TimeMgr.tick_ts
	if soldier_count < max_soldier_count:
		e.play_animation_by_look(barrack_c.animation)
		AudioMgr.play_sfx(barrack_c.sfx)
		if await e.y_wait(barrack_c.delay):
			return

		_spawn_soldier(e, barrack_c, soldier_group)
		
		barrack_c.new_rally_center_position(barrack_c.rally_center_position, false, false)
		barrack_c.last_soldier_count = soldier_group.get_child_count()
		e.y_wait_animation(barrack_c.animation)


func _spawn_all_soldiers(e: Entity, barrack_c: BarrackComponent) -> void:
	var soldier_group: EntityGroup = barrack_c.soldier_group
	var last_soldier_group: EntityGroup = barrack_c.last_soldier_group
	var has_replace_all: bool = true

	# 先替换存活的士兵
	if last_soldier_group:
		var last_soldier_group_count: int = last_soldier_group.get_child_count()
		
		for i: int in barrack_c.max_soldier_count:
			if i >= last_soldier_group_count:
				has_replace_all = false
				break
				
			var soldier: Entity = _spawn_soldier(e, barrack_c, soldier_group)
			var last_soldier: Entity = last_soldier_group.get_child(i)

			soldier.global_position = last_soldier.global_position

			if last_soldier.state & Entity.State.RALLY:
				continue

			var last_melee_c: MeleeComponent = last_soldier.get_node_or_null(C.CN_MELEE)
			if last_melee_c:
				var melee_c: MeleeComponent = soldier.get_node_or_null(C.CN_MELEE)
				if melee_c:
					soldier.state = Entity.State.MELEE

					if melee_c.is_blocker:
						for blocked_id: int in last_melee_c.blocked_id_list:
							melee_c.bind_melee_relations(soldier.id, blocked_id)
					else:
						for blocker_id: int in last_melee_c.blocker_id_list:
							melee_c.bind_melee_relations(blocker_id, soldier.id)
		
		barrack_c.last_soldier_count = soldier_group.get_child_count()
		barrack_c.new_rally_center_position(barrack_c.rally_center_position, false)
	else:
		has_replace_all = false

	if not has_replace_all:
		e.play_animation_by_look(barrack_c.animation)
		AudioMgr.play_sfx(barrack_c.sfx)
		if await e.y_wait(barrack_c.delay):
			return

		var max_soldier_count: int = barrack_c.max_soldier_count

		# 生成新的士兵
		for i: int in range(soldier_group.get_child_count(), max_soldier_count):
			_spawn_soldier(e, barrack_c, soldier_group)

		barrack_c.new_rally_center_position(barrack_c.rally_center_position, false)
		barrack_c.last_soldier_count = soldier_group.get_child_count()
		
		e.y_wait_animation(barrack_c.animation)
