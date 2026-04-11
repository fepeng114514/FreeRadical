extends Node
class_name Behavior
## 行为类


#region 回调函数
@warning_ignore_start("unused_parameter")
## 插入实体时调用，返回 false 的实体将会被移除
func _on_insert(e: Entity) -> bool: return true


## 移除实体时调用，返回 false 的实体将不会被移除
func _on_remove(e: Entity) -> bool: return true


## 更新实体时调用，返回 true 的实体表示阻断后续行为
func _on_update(e: Entity) -> bool: return false


## 任意一个行为的更新回调返回 false 时调用
func _on_return_false(e: Entity) -> void: pass


## 任意一个行为的更新回调返回 true 时调用
func _on_return_true(e: Entity, break_behavior: Behavior) -> void: pass
@warning_ignore_restore("unused_parameter")
#endregion


func can_attack(a: Variant, target: Entity) -> bool:
	return (
		target 
		and not U.is_mutual_ban(target.flag_bits, a.ban_bits, a.flag_bits, target.ban_bits)
		and U.is_allowed_entity(a, target)
	)


func go_melee_pos(e: Entity, melee_c: MeleeComponent) -> bool:
	if melee_c.melee_pos_arrived or U.is_at_destination(
			e.global_position, melee_c.melee_pos, melee_c.arrived_distance
	):
		melee_c.melee_pos_arrived = true
		return true
	
	var direction: Vector2 = e.global_position.direction_to(
		melee_c.melee_pos
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
	
	
func back_origin_pos(e: Entity, melee_c: MeleeComponent) -> bool:
	if melee_c.origin_pos_arrived or U.is_at_destination(
		e.global_position, melee_c.origin_pos, melee_c.arrived_distance
	):
		melee_c.origin_pos_arrived = true
		return true
	
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
	

func try_melee_attack(e: Entity, melee_c: MeleeComponent, target: Entity) -> void:
	for a: MeleeAttack in melee_c.list:
		if not TimeMgr.is_ready_time(a.ts, a.cooldown):
			continue

		if not can_attack(a, target):
			continue
			
		Log.verbose("近战攻击: %s" % e)

		e.look_point = target.global_position
		e.play_animation_by_look(a.animation, "melee")
		await e.y_wait(a.delay, func() -> bool:
			return not U.is_valid_entity(target)
		)
		a.ts = TimeMgr.tick_ts
		
		if not U.is_valid_entity(target):
			return
			
		var targets: Array[Entity] = [null]
			
		if a.damage_min_radius > 0 or a.damage_max_radius > 0:
			targets = EntityMgr.search_targets(
				a.damage_search_mode, 
				target.global_position + a.damage_offset, 
				a.damage_max_radius, 
				a.damage_min_radius, 
				e.flag_bits, 
				e.ban_bits,
				func(t: Entity) -> bool:
					return a.can_damage_same or t.id not in a.damaged_entity_ids
			)
		else:
			targets[0] = target
		
		for i: int in range(targets.size()):
			if i > a.damage_max_count:
				break
				
			var t: Entity = targets[i]
			
			var d := Damage.new()
			d.target_id = t.id
			d.source_id = e.id
			d.value = d.get_random_value(a.damage_min, a.damage_max)
			d.damage_type = a.damage_type
			d.damage_flags = a.damage_flag_bits
			d.insert_damage()

			EntityMgr.create_mods(t.id, a.mods, e.id)
			a.damaged_entity_ids.append(t.id)
		
		await e.wait_animation(a.animation)
		e.play_animation_by_look(e.idle_animation)
		break


## 从被拦截者中擦除拦截者
func erase_blocker_from_blockeds(
		erase_id: int, melee_c: MeleeComponent
	) -> void:
	for blocked_id: int in melee_c.blockeds_ids:
		var blocked: Entity = EntityMgr.get_entity_by_id(blocked_id)
		var blocked_melee_c: MeleeComponent = blocked.get_c(C.CN_MELEE)
		blocked_melee_c.blockers_ids.erase(erase_id)


## 从拦截者中擦除被拦截者
func erase_blocked_from_blockers(
		erase_id: int, melee_c: MeleeComponent
	) -> void:
	for blocker_id: int in melee_c.blockers_ids:
		var blocker: Entity = EntityMgr.get_entity_by_id(blocker_id)
		var blocker_melee_c: MeleeComponent = blocker.get_c(C.CN_MELEE)
		blocker_melee_c.blockeds_ids.erase(erase_id)
