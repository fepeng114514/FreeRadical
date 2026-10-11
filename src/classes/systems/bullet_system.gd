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
	bullet_c.timestamp = TimeManager.tick_timestamp
	var bullet_c_config: BulletComponentNodeConfig = bullet_c.config
	var predict_time: float = bullet_c_config.trajectory._get_predict_time() if bullet_c_config.trajectory else 0.0
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
	if bullet_c_config.facing_enabled:
		entity.look_at(to)

	if bullet_c_config.trajectory:
		bullet_c_config.trajectory._init_trajectory(entity, bullet_c, target)

	var damage_influence := bullet_c_config.influence as DamageInfluence
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
	for bullet: Entity in EntityManager.get_component_entity_group(Constants.BULLET_COMPONENT_NAME):
		if bullet.is_waiting() or bullet.state & Entity.State.REMOVED:
			continue

		var bullet_c: BulletComponent = bullet.get_node_or_null(Constants.BULLET_COMPONENT_NODE_PATH)
		if not bullet_c:
			continue
			
		var animated_sprite_c: AnimatedSpriteComponent = bullet.get_node_or_null(Constants.ANIMATED_SPRITE_COMPONENT_NODE_PATH)
		var bullet_c_config: BulletComponentNodeConfig = bullet_c.config
		var trajectory: BulletTrajectory = bullet_c_config.trajectory
		if not trajectory:
			continue
			
		var target: Entity = EntityManager.get_entity_by_id(bullet.target_id)
		var flying_time: float = TimeManager.get_elapsed_time(bullet_c.timestamp)

		trajectory._update_trajectory(bullet, bullet_c, target, flying_time, delta)
		
		if bullet_c_config.flight_animation:
			animated_sprite_c.play_animation(bullet, bullet_c_config.flight_animation)
		bullet.rotation += bullet_c_config.rotation_speed * delta

		if target:
			if trajectory._can_hit(bullet, bullet_c, flying_time):
				_hit(bullet, bullet_c, target, animated_sprite_c)
		else:
			if trajectory._can_miss(bullet, bullet_c, flying_time):
				_miss(bullet, bullet_c, animated_sprite_c)


## 处理命中。
func _hit(bullet: Entity, bullet_c: BulletComponent, target: Entity, animated_sprite_c: AnimatedSpriteComponent) -> void:
	var bullet_c_config: BulletComponentNodeConfig = bullet_c.config
	AudioManager.play_sfx(bullet_c_config.hit_sfx)
	if bullet_c_config.hit_animation:
		animated_sprite_c.play_animation(bullet, bullet_c_config.hit_animation)
		if await bullet.y_wait(bullet_c_config.hit_delay):
			return
		
	bullet_c_config.influence.take_influence(bullet, target, bullet_c.to)
	EntityManager.create_entities_at_global_position(bullet_c_config.hit_payloads, bullet_c.to)
	
	if bullet_c_config.hit_animation:
		if await animated_sprite_c.y_wait_animation(bullet, bullet_c_config.hit_animation):
			return

	if bullet_c_config.hit_remove:
		EntityManager.queue_remove_entity(bullet)


## 处理未击中。
func _miss(bullet: Entity, bullet_c: BulletComponent, animated_sprite_c: AnimatedSpriteComponent) -> void:
	var bullet_c_config: BulletComponentNodeConfig = bullet_c.config
	AudioManager.play_sfx(bullet_c_config.miss_sfx)
	if bullet_c_config.miss_animation:
		animated_sprite_c.play_animation(bullet, bullet_c_config.miss_animation)
		if await bullet.y_wait(bullet_c_config.miss_delay):
			return

	var influence: Influence = bullet_c_config.influence
	if influence and bullet_c_config.miss_influence_enabled:
		influence.take_influence(bullet, null, bullet_c.to)
	EntityManager.create_entities_at_global_position(bullet_c_config.miss_payloads, bullet_c.to)

	if bullet_c_config.miss_animation:
		if await animated_sprite_c.y_wait_animation(bullet, bullet_c_config.miss_animation):
			return

	if bullet_c_config.miss_remove:
		EntityManager.queue_remove_entity(bullet)
				
				