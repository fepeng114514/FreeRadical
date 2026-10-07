extends System
class_name BulletSystem
## 子弹系统。
##
## BulletSystem 负责处理拥有 [BulletComponent] 子弹组件的实体的飞行轨迹、命中检测和伤害计算等相关逻辑。


func _on_insert(entity: Entity) -> bool:
	var bullet_c: BulletComponent = entity.get_node_or_null(Constants.BULLET_COMPONENT_NODE_PATH)
	if not bullet_c:
		return true

	var target: Entity = EntityManager.get_entity_by_id(entity.target_id)
	if not target:
		return false
		
	target.aimed_bullet_ids.append(entity.id)
	target.has_new_aimed_bullet = true
	bullet_c.time_stamp = TimeManager.tick_time_stamp
	var predict_time: float = bullet_c.config.trajectory._get_predict_time() if bullet_c.config.trajectory else 0.0
	if predict_time:
		bullet_c.predicted_target_global_position = PathwayManager.predict_target_global_position(
			target, predict_time
		)
	else:
		bullet_c.predicted_target_global_position = target.global_position
	
	var to: Vector2 = bullet_c.predicted_target_global_position
	if target.config.hit_offsets:
		var hit_offset: Vector2 = target.config.hit_offsets.get_offset_toward_point(
			target.global_position, target.facing_global_position
		)
		to += hit_offset
	bullet_c.to = to
	bullet_c.from = entity.global_position
	if bullet_c.config.facing_enabled:
		entity.look_at(to)

	if bullet_c.config.trajectory:
		bullet_c.config.trajectory._init_trajectory(entity, bullet_c, target)

	var damage_influence := bullet_c.config.hit_influence as DamageInfluence
	if damage_influence:
		match damage_influence.get_value_mode:
			damage_influence.GetValueMode.RANDOM:
				damage_influence.value = randf_range(damage_influence.min_value, damage_influence.max_value)

	return true


func _on_remove(entity: Entity) -> bool:
	var bullet_c: BulletComponent = entity.get_node_or_null(Constants.BULLET_COMPONENT_NODE_PATH)
	if not bullet_c:
		return true
		
	var target: Entity = EntityManager.get_entity_by_id(entity.target_id)
	if not target:
		return true
		
	target.aimed_bullet_ids.erase(entity.id)
	return true


func _on_update(delta: float) -> void:
	for entity: Entity in EntityManager.get_component_entity_group(Constants.BULLET_COMPONENT_NAME):
		if entity.is_waiting() or entity.state & Entity.State.REMOVED:
			continue

		var bullet_c: BulletComponent = entity.get_node_or_null(Constants.BULLET_COMPONENT_NODE_PATH)
		if not bullet_c or not bullet_c.config.trajectory:
			continue
			
		var target: Entity = EntityManager.get_entity_by_id(entity.target_id)
		var flying_time: float = TimeManager.get_elapsed_time(bullet_c.time_stamp)

		bullet_c.config.trajectory._update_trajectory(entity, bullet_c, target, flying_time, delta)
		
		if bullet_c.config.flight_animation:
			entity.play_animation(bullet_c.config.flight_animation)
		entity.rotation += bullet_c.config.rotation_speed * delta

		if target:
			if bullet_c.config.trajectory._can_hit(entity, bullet_c, flying_time):
				_hit(entity, bullet_c, target)
		else:
			if bullet_c.config.trajectory._can_miss(entity, bullet_c, flying_time):
				_miss(entity, bullet_c)


## 未击中处理。
func _miss(entity: Entity, bullet_c: BulletComponent) -> void:
	AudioManager.play_sfx(bullet_c.config.miss_sfx)
	if bullet_c.config.miss_animation:
		entity.play_animation(bullet_c.config.miss_animation)
		if await entity.y_wait_animation(bullet_c.config.miss_animation):
			return

	var influence: Influence = bullet_c.config.hit_influence
	if influence and influence.area_enabled:
		influence.take_influence(entity, null, bullet_c.to)
	EntityManager.create_entities_at_global_position(bullet_c.config.miss_payloads, bullet_c.to)

	if bullet_c.config.miss_animation:
		if await entity.y_wait_animation(bullet_c.config.miss_animation):
			return

	if bullet_c.config.miss_remove:
		EntityManager.queue_remove_entity(entity)
				
				
## 命中处理。
func _hit(entity: Entity, bullet_c: BulletComponent, target: Entity) -> void:
	AudioManager.play_sfx(bullet_c.config.hit_sfx)
	if bullet_c.config.hit_animation:
		entity.play_animation(bullet_c.config.hit_animation)
		if await entity.y_wait(bullet_c.config.hit_delay):
			return
		
	bullet_c.config.hit_influence.take_influence(entity, target, bullet_c.to)
	EntityManager.create_entities_at_global_position(bullet_c.config.hit_payloads, bullet_c.to)
	
	if bullet_c.config.hit_animation:
		if await entity.y_wait_animation(bullet_c.config.hit_animation):
			return

	if bullet_c.config.hit_remove:
		EntityManager.queue_remove_entity(entity)
