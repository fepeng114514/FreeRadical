extends System
class_name BulletSystem
## 子弹系统
##
## 处理拥有 [BulletComponent] 子弹组件的实体的飞行轨迹、命中检测和伤害计算等相关逻辑。


func _on_insert(e: Entity) -> bool:
	var bullet_c: BulletComponent = e.get_node_or_null(C.CN_BULLET)
	if not bullet_c:
		return true

	var target: Entity = EntityMgr.get_entity_by_id(e.target_id)
	if not target:
		return false

	bullet_c.ts = TimeMgr.tick_ts
	var predict_time: float = bullet_c.trajectory._get_predict_time() if bullet_c.trajectory else 0.0
	if predict_time:
		bullet_c.predict_target_pos = PathwayMgr.predict_target_pos(
			target, predict_time
		)
	else:
		bullet_c.predict_target_pos = target.global_position
	
	var to: Vector2 = bullet_c.predict_target_pos
	if target.hit_offsets:
		var hit_offset: Vector2 = target.hit_offsets.get_offset_for_point(
			target.global_position, target.look_point
		)
		to += hit_offset
	bullet_c.to = to
	bullet_c.from = e.global_position
	if bullet_c.look_to:
		e.look_at(to)

	if bullet_c.trajectory:
		bullet_c.trajectory._init_trajectory(bullet_c, e, target)

	return true


func _on_update(delta: float) -> void:
	var entity_list: Array = EntityMgr.get_entities_group(C.CN_BULLET).filter(
		func(e: Entity) -> bool:
			return not e.is_waiting() and not e.state & Entity.State.REMOVED
	)

	for e: Entity in entity_list:
		var bullet_c: BulletComponent = e.get_node_or_null(C.CN_BULLET)
		if not bullet_c or not bullet_c.trajectory:
			continue
			
		var target: Entity = EntityMgr.get_entity_by_id(e.target_id)
		var flying_time: float = TimeMgr.get_time_by_ts(bullet_c.ts)

		bullet_c.trajectory._update_trajectory(e, bullet_c, target, flying_time, delta)
		
		if bullet_c.flight_animation:
			e.play_animation_by_look(bullet_c.flight_animation)
		e.rotation += bullet_c.rotation_speed * delta

		# 未击中处理
		if (
			bullet_c.trajectory._should_miss(bullet_c, flying_time)
			or not target
			and U.is_at_destination(
				e.global_position, bullet_c.to, bullet_c.hit_distance
			)
		):
			_miss(e, bullet_c)
		else:
			if not bullet_c.can_arrived:
				continue
			
			if not bullet_c.trajectory._has_arrived(e, bullet_c, flying_time):
				continue
				
			_hit(e, bullet_c, target)

		
func _miss(e: Entity, bullet_c: BulletComponent) -> void:
	e._on_bullet_miss(bullet_c)
	
	AudioMgr.play_sfx(bullet_c.miss_sfx)
	if bullet_c.miss_animation:
		e.play_animation_by_look(bullet_c.miss_animation)
		await e.wait_animation(bullet_c.miss_animation)

	var influence: InfluenceResource = bullet_c.influence
	if influence and influence.area_enable:
		influence.take(e, null, bullet_c.to)
	EntityMgr.create_entities_at_pos(bullet_c.miss_payloads, bullet_c.to)

	if bullet_c.miss_remove:
		e.remove_entity()
				
		
func _hit(e: Entity, bullet_c: BulletComponent, target: Entity) -> void:
	AudioMgr.play_sfx(bullet_c.hit_sfx)
	if bullet_c.hit_animation:
		e.play_animation_by_look(bullet_c.hit_animation)
		await e.y_wait(bullet_c.hit_delay)
		
	bullet_c.influence.take(e, target, bullet_c.to)
	EntityMgr.create_entities_at_pos(bullet_c.hit_payloads, bullet_c.to)
	e._on_bullet_hit(target, bullet_c)
	
	if bullet_c.hit_animation:
		e.wait_animation(bullet_c.hit_animation)
		await e.wait_animation(bullet_c.hit_animation)

	if bullet_c.hit_remove:
		e.remove_entity()
		
