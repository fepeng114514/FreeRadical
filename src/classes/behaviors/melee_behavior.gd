extends Behavior
class_name MeleeBehavior
## 近战行为。
##
## MeleeBehavior 负责处理拥有 [MeleeComponent] 组件的实体的近战技能释放与拦截。


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
	else:
		melee_c.blocker_id_list.clear()
		
	if e.state & Entity.State.IDLE:
		melee_c.origin_pos = e.global_position


func _on_update(e: Entity) -> bool:
	var melee_c: MeleeComponent = e.get_node_or_null(C.CN_MELEE)
	if not melee_c:
		return false
		
	if e.interact_policy:
		if e.interact_policy.flags & C.Flag.FRIENDLY:
			melee_c.is_blocker = true
		else:
			melee_c.is_blocker = false
			
	melee_c.cleanup_melee_relations(e)
	
	if melee_c.is_blocker:
		return _update_blocker(e, melee_c)
	else:
		return _update_blocked(e, melee_c)


## 更新拦截者。
func _update_blocker(e: Entity, melee_c: MeleeComponent) -> bool:
	if melee_c.blocked_count < melee_c.max_blocked_count or melee_c.is_extra_blocker:
		_blocker_search_and_bind_melee_relations(e, melee_c)
	
	var blocked_id_list: PackedInt32Array = melee_c.blocked_id_list
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
		var blocked_global_pos: Vector2 = blocked.global_position
		var blocked_melee_c: MeleeComponent = blocked.get_node_or_null(C.CN_MELEE)
		
		if melee_c.is_passive:
			if blocked_melee_c.melee_state != MeleeComponent.MeleeState.MELEE_POS_ARRIVED:
				e.look_point = blocked_global_pos
				e.play_animation(e.idle_animation)
				return true
		else:
			var melee_pos: Vector2 = blocked_global_pos
			if blocked_melee_c.melee_pos_offsets:
				var melee_pos_offset: Vector2 = blocked_melee_c.melee_pos_offsets.get_offset_for_point(
					melee_pos, e.global_position
				)
				melee_pos += melee_pos_offset

			melee_c.melee_pos = melee_pos
			if not _go_melee_pos(e, melee_c, melee_pos):
				return true
		
		_try_melee_attack(e, melee_c, blocked)
		return true


## 拦截者搜索目标
func _blocker_search_and_bind_melee_relations(e: Entity, melee_c: MeleeComponent) -> void:
	var center: Vector2 = e.global_position
	var rally_c: RallyComponent = e.get_node_or_null(C.CN_RALLY)
	if rally_c:
		var rally_center_position: Vector2 = rally_c.rally_center_position
		
		if rally_center_position != Vector2.ZERO:
			center = rally_center_position
	
	# 1. 首先搜索没有被拦截的目标
	var pending_blockeds: Array[Entity] = melee_c.searcher.search_targets(
		center,
		e,
		func(t: Entity) -> bool:
			var t_melee_c: MeleeComponent = t.get_node_or_null(C.CN_MELEE)
			if not t_melee_c:
				return false

			if t_melee_c.is_passive and melee_c.is_passive:
				return false

			return not t_melee_c.blocker_id_list
	)
	
	if pending_blockeds:
		# 先解除额外拦截者关系
		if melee_c.is_extra_blocker:
			if melee_c.blocked_id_list:
				var first_blocked_id: int = melee_c.blocked_id_list[0]
				var first_blocked_target: Entity = EntityMgr.get_entity_by_id(first_blocked_id)
				var blocked_melee_c: MeleeComponent = first_blocked_target.get_node_or_null(C.CN_MELEE)
				if blocked_melee_c.blocker_id_list.size() > 1:
					melee_c.blocked_count -= blocked_melee_c.block_cost
					melee_c.unbind_melee_relations(e.id)

			melee_c.is_extra_blocker = false
		
		var max_blocked_count: int = melee_c.max_blocked_count
		for t: Entity in pending_blockeds:
			if melee_c.blocked_count >= max_blocked_count:
				break

			var t_melee_c: MeleeComponent = t.get_node_or_null(C.CN_MELEE)

			if t_melee_c.is_passive and melee_c.blocked_id_list:
				continue
			
			melee_c.bind_melee_relations(e.id, t.id)
	else:
		# 2. 处理额外拦截者，搜索第一个被拦截的目标
		if not melee_c.blocked_id_list and not melee_c.is_passive:
			var blocked_targets: Array[Entity] = melee_c.searcher.search_targets(
				center,
				e,
				func(t: Entity) -> bool:
					var t_melee_c: MeleeComponent = t.get_node_or_null(C.CN_MELEE)
					if not t_melee_c:
						return false

					if t_melee_c.is_passive and melee_c.is_passive:
						return false
						
					return true
			)
			var first_blocked_target: Entity = blocked_targets[0] if blocked_targets else null
			if first_blocked_target:
				melee_c.bind_melee_relations(e.id, first_blocked_target.id)
				melee_c.is_extra_blocker = true
	

## 更新被拦截者。
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

		if is_first_blocked and not blocker_melee_c.is_passive:
			if blocker_melee_c.melee_state != MeleeComponent.MeleeState.MELEE_POS_ARRIVED:
				e.look_point = blocker_global_pos
				e.play_animation(e.idle_animation)
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
	

## 前往近战位置。
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
		e.play_animation(melee_c.motion_animation, &"walk")
		e.global_position = next_position
		
		return false
	

## 返回原点。
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
		e.play_animation(melee_c.motion_animation, &"walk")

		e.global_position = next_position
		
		return false
	

## 尝试近战技能。
func _try_melee_attack(
		e: Entity, melee_c: MeleeComponent, target: Entity
	) -> void:
	if U.is_valid_entity(target):
		e.look_point = target.global_position
	e.play_animation(e.idle_animation)
	
	for i: int in melee_c.get_child_count():
		if not target:
			break
		var skill: MeleeSkill = melee_c.get_child(i)

		if not skill.check_ready(e, target):
			continue

		skill._do_skill(e, i, target)
		break
