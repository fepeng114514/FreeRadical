extends Behavior
class_name MeleeBehavior
## 近战行为系统
##
## 处理拥有 [MeleeComponent] 组件的实体的近战技能释放与拦截。
## 若 [member MeleeComponent.is_blocker] 为 `true`，作为拦截者：搜索并标记被拦截者，前往第一个被拦截者的近战位置。
## 若 [member MeleeComponent.is_blocked] 为 `true`，作为被拦截者：根据是否第一个被拦截者决定等待拦截者到达，或主动前往拦截者的近战位置。


func _on_remove(e: Entity) -> bool:
	var melee_c: MeleeComponent = e.get_node_or_null(C.CN_MELEE)
	if not melee_c:
		return true
	
	melee_c.cleanup_melee_relations(e)
	melee_c.unbind_melee_relations(e.id)
	
	return true


func _on_skip(e: Entity) -> void:
	var melee_c: MeleeComponent = e.get_node_or_null(C.CN_MELEE)
	if not melee_c:
		return
	
	melee_c.unbind_melee_relations(e.id)
	if melee_c.is_blocker:
		melee_c.blocked_id_list.clear()
		melee_c.blocked_count = 0
		melee_c.melee_state = MeleeComponent.MeleeState.ORIGIN_POS_ARRIVED
	elif melee_c.is_blocked:
		melee_c.blocker_id_list.clear()
		
	if e.state & Entity.State.IDLE:
		melee_c.origin_pos = e.global_position


func _on_update(e: Entity) -> bool:
	var melee_c: MeleeComponent = e.get_node_or_null(C.CN_MELEE)
	if not melee_c:
		return false
		
	melee_c.cleanup_melee_relations(e)
	
	if melee_c.is_blocker:
		return _update_blocker(e, melee_c)
	elif melee_c.is_blocked:
		return _update_blocked(e, melee_c)
		
	return false


func _update_blocker(e: Entity, melee_c: MeleeComponent) -> bool:
	if not melee_c.blocked_id_list:
		melee_c.is_extra_blocker = false

	var e_global_pos: Vector2 = e.global_position
	
	# 索敌
	var center: Vector2 = e_global_pos
	var rally_c: RallyComponent = e.get_node_or_null(C.CN_RALLY)
	if rally_c:
		var rally_center_position: Vector2 = rally_c.rally_center_position
		
		if rally_center_position != Vector2.ZERO:
			center = rally_center_position
	
	var pending_blockeds: Array[Entity] = melee_c.search.search_targets(
		e,
		center,
		func(t: Entity) -> bool:
			var t_melee_c: MeleeComponent = t.get_node_or_null(C.CN_MELEE)
			if not t_melee_c:
				return false
			return not t_melee_c.blocker_id_list
	)
	
	if pending_blockeds:
		if melee_c.blocked_id_list and melee_c.is_extra_blocker:
			var first_blocked_id: int = melee_c.blocked_id_list[0]
			var first_blocked_target: Entity = EntityMgr.get_entity_by_id(first_blocked_id)
			var blocked_melee_c: MeleeComponent = first_blocked_target.get_node_or_null(C.CN_MELEE)
			if blocked_melee_c.blocker_id_list.size() > 1:
				melee_c.blocked_count = 0
				melee_c.unbind_melee_relations(e.id)
		
		var max_blocked: int = melee_c.max_blocked
		for t: Entity in pending_blockeds:
			if melee_c.blocked_count >= max_blocked:
				break
			
			melee_c.bind_melee_relations(t, e)
	else:
		if not melee_c.blocked_id_list:
			var blocked_targets: Array[Entity] = melee_c.search.search_targets(
				e,
				center,
				func(t: Entity) -> bool:
				var t_melee_c: MeleeComponent = t.get_node_or_null(C.CN_MELEE)
				if not t_melee_c:
					return false
					
				return true
			)
			var first_blocked_target: Entity = blocked_targets[0] if blocked_targets else null
			if first_blocked_target and not melee_c.is_extra_blocker:
				melee_c.bind_melee_relations(first_blocked_target, e)
				melee_c.is_extra_blocker = true
	
	var blocked_id_list: Array = melee_c.blocked_id_list
	if not blocked_id_list:
		match melee_c.melee_state:
			MeleeComponent.MeleeState.ORIGIN_POS_ARRIVED:
				melee_c.origin_pos = e.global_position
			_:
				if not _back_origin_pos(e, melee_c):
					return true
		
		return false
	else:
		e.state = Entity.State.MELEE
		var blocked: Entity = EntityMgr.get_entity_by_id(blocked_id_list[0])
		var blocked_melee_c: MeleeComponent = blocked.get_node_or_null(C.CN_MELEE)
		
		# 不是被动被拦截者，前往近战位置
		if not melee_c.is_passive:
			var melee_pos: Vector2 = blocked.global_position
			if blocked_melee_c.melee_pos_offsets:
				var melee_pos_offset: Vector2 = blocked_melee_c.melee_pos_offsets.get_offset_for_point(
					melee_pos, e_global_pos
				)
				melee_pos += melee_pos_offset

			melee_c.melee_pos = melee_pos
			if not _go_melee_pos(e, melee_c, melee_pos):
				return true
		
		_try_melee_attack(e, melee_c, blocked)
		return true


func _update_blocked(e: Entity, melee_c: MeleeComponent) -> bool:
	var e_global_pos: Vector2 = e.global_position
	var blocker_id_list: PackedInt32Array = melee_c.blocker_id_list
	if not blocker_id_list:
		match melee_c.melee_state:
			MeleeComponent.MeleeState.ORIGIN_POS_ARRIVED:
				melee_c.origin_pos = e_global_pos
			_:
				if not _back_origin_pos(e, melee_c):
					return true
		
		return false
	else:
		e.state = Entity.State.MELEE
		var blocker: Entity = EntityMgr.get_entity_by_id(blocker_id_list[0])
		var blocker_global_pos: Vector2 = blocker.global_position
		var blocker_melee_c: MeleeComponent = blocker.get_node_or_null(C.CN_MELEE)
		var is_first_blocked: bool = e.id == blocker_melee_c.blocked_id_list[0]

		if is_first_blocked:
			if blocker_melee_c.melee_state != MeleeComponent.MeleeState.MELEE_POS_ARRIVED:
				e.look_point = blocker_global_pos
				e.play_animation_by_look(e.idle_animation)
				return true
		else:
			if not melee_c.is_passive:
				var melee_pos: Vector2 = blocker_global_pos
				if blocker_melee_c.melee_pos_offsets:
					var melee_pos_offset: Vector2 = blocker_melee_c.melee_pos_offsets.get_offset_for_point(
						blocker_global_pos, e_global_pos
					)
					melee_pos += melee_pos_offset

				melee_c.melee_pos = melee_pos
				if not _go_melee_pos(e, melee_c, melee_pos):
					return true
		
		_try_melee_attack(e, melee_c, blocker)
		return true
	
	
func _go_melee_pos(e: Entity, melee_c: MeleeComponent, melee_pos: Vector2) -> bool:
	if U.is_at_destination(
			e.global_position, melee_pos, melee_c.arrived_distance	 
	):
		#Log.verbose("Arrived! Pos: %s, Target: %s, Dist: %s" % [e.global_position, melee_c.melee_pos, e.global_position.distance_to(melee_c.melee_pos)])
		melee_c.melee_state = MeleeComponent.MeleeState.MELEE_POS_ARRIVED
		return true
	else:
		#Log.verbose("Moving to %s, current %s, velocity %s" % [melee_c.melee_pos, e.global_position, melee_c.velocity])
		melee_c.melee_state = MeleeComponent.MeleeState.MELEE_POS_MOVING
		var direction: Vector2 = e.global_position.direction_to(melee_pos)
		var velocity: Vector2 = (
			direction 
			* melee_c.speed 
			* TimeMgr.frame_length
		)
		melee_c.velocity = velocity

		var next_position: Vector2 = e.global_position + velocity
		e.look_point = next_position
		e.play_animation_by_look(melee_c.motion_animation, "walk")
		e.global_position = next_position
		
		return false
	
	
func _back_origin_pos(e: Entity, melee_c: MeleeComponent) -> bool:
	if U.is_at_destination(
		e.global_position, melee_c.origin_pos, melee_c.arrived_distance
	):
		melee_c.melee_state = MeleeComponent.MeleeState.ORIGIN_POS_ARRIVED
		e.state = Entity.State.IDLE
		return true
	else:
		melee_c.melee_state = MeleeComponent.MeleeState.ORIGIN_POS_MOVING
		var direction: Vector2 = e.global_position.direction_to(
			melee_c.origin_pos
		)
		var velocity: Vector2 = (
			direction 
			* melee_c.speed 
			* TimeMgr.frame_length
		)
		melee_c.velocity = velocity

		var next_position: Vector2 = e.global_position + velocity
		e.look_point = next_position
		e.play_animation_by_look(melee_c.motion_animation, "walk")

		e.global_position = next_position
		
		return false
	

func _try_melee_attack(
		e: Entity, melee_c: MeleeComponent, target: Entity
	) -> void:
	if U.is_valid_entity(target):
		e.look_point = target.global_position
	e.play_animation_by_look(e.idle_animation)
	
	for skill: SkillMelee in melee_c.get_children():
		if not TimeMgr.is_ready_time(skill.ts, skill.cooldown):
			continue

		if not Skill.can_attack(skill, target):
			continue
			
		Log.verbose("近战攻击: %s" % e)

		skill.ts = TimeMgr.tick_ts
		e.play_animation_by_look(skill.animation, "melee")
		await e.y_wait(skill.delay)
			
		skill.influence.take(e, target, e.global_position)
		
		await e.wait_animation(skill.animation)
		e.play_animation_by_look(e.idle_animation)
		break
