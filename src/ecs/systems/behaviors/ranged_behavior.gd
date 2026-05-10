extends Behavior
class_name RangedBehavior
## 远程攻击行为系统
##
## 处理拥有 [RangedComponent] 远程攻击组件的实体的远程攻击


func _on_update(e: Entity) -> bool:
	var ranged_c: RangedComponent = e.get_node_or_null(C.CN_RANGED)
	if not ranged_c:
		return false
		
	for i: int in ranged_c.get_child_count():
		var a: RangedBase = ranged_c.get_child(i)
		
		if not TimeMgr.is_ready_time(a.ts, a.cooldown):
			continue
			
		var target: Entity = EntityMgr.get_entity_by_id(e.target_id)
		
		if not target and not ranged_c.disabled_search:
			var targets: Array[Entity] = EntityMgr.search_targets(
				a.search_mode, 
				e.global_position, 
				a.max_range, 
				a.min_range, 
				a.flags, 
				a.bans
			)
			if targets:
				target = targets[0]
			
		if not can_attack(a, target):
			continue
					
		var tick_ts: float = TimeMgr.tick_ts
		a.ts = tick_ts
		e.look_point = target.global_position
		
		if not a.group_cooldown_disabled:
			var parent: Node = e.get_parent()
			if parent is EntityGroup2D:
				for member: Entity in parent.get_children():
					if member == e:
						continue
					
					var member_ranged_c: RangedComponent = member.get_node_or_null(C.CN_RANGED)
					if not member_ranged_c:
						continue
						
					var member_a: RangedBase = member_ranged_c.get_child(i)
					member_a.ts = tick_ts - a.group_cooldown_offset
		
		if a is RangedAttack:
			_do_single_attack(a, e, target)
		elif a is RangedLoopAttack:
			_do_loop_attack(a, e, target)
			
		return true
			
	return false
	
	
func _do_single_attack(a: RangedAttack, e: Entity, target: Entity) -> void:
	var result: Array = e.play_animation_by_look(a.animation, "ranged")
	AudioMgr.play_sfx(a.sfx)
	await e.y_wait(a.delay)
	var direction: C.Direction = result[1]

	if not target:
		return

	_spawn_bullets(a, e, target, direction)

	await e.wait_animation(a.animation)


func _do_loop_attack(a: RangedLoopAttack, e: Entity, target: Entity) -> void:
	e.play_animation_by_look(a.start_animation, "ranged")
	AudioMgr.play_sfx(a.start_sfx)
	await e.wait_animation(a.start_animation)

	if not target:
		return

	for i: int in a.loop_count:
		if not U.is_valid_entity(target):
			break
			
		e.look_point = target.global_position
		var result: Array = e.play_animation_by_look(a.loop_animation)
		var direction: C.Direction = result[1]

		AudioMgr.play_sfx(a.loop_sfx)
		await e.y_wait(a.delay)

		_spawn_bullets(a, e, target, direction)
		await e.wait_animation(a.loop_animation)

	await e.wait_animation(a.loop_animation)

	e.play_animation_by_look(a.end_animation)
	AudioMgr.play_sfx(a.end_sfx)
	await e.wait_animation(a.end_animation)


func _spawn_bullets(
		a: RangedBase, 
		e: Entity, 
		target: Entity, 
		direction: C.Direction,
	) -> void:
	var e_to_target_angle: float = e.global_position.angle_to_point(target.global_position)
	var bullet_count: int = a.bullet_count
	var bullet_angle_range: float = a.bullet_angle_range
	var half_angle_range: float = bullet_angle_range / 2
	var da: float = (bullet_angle_range) / bullet_count + 1
	
	for i: int in bullet_count:
		var b = EntityMgr.create_entity(a.bullet)
		b.target_id = target.id
		b.source_id = e.id

		var rotation: float = 0
		match a.bullet_spawn_mode:
			C.BulletSpawnMode.EQUAL_INTERVAL:
				rotation = e_to_target_angle + (da * i + -half_angle_range)
			C.BulletSpawnMode.RANDOM:
				var random_angle: float = randf_range(
					-half_angle_range, half_angle_range	
				)
				rotation = e_to_target_angle + random_angle
				
		b.rotation = rotation
		b.global_position = e.global_position + a.bullet_offsets.get_offset_by_direction(direction)
		
		var b_bullet_c: BulletComponent = b.get_node_or_null(C.CN_BULLET)
		b_bullet_c.data = a.bullet_data.duplicate_deep()

		b.insert_entity()
