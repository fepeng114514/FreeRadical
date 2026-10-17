extends System
class_name DamageSystem
## 伤害系统。
##
## [DamageSystem] 负责处理 [member DamageManager.damage_queue] 中的伤害造成。


func _on_update(_delta: float) -> void:
	# 用于存储循环中创建的伤害。
	var new_damage_queue: Array[Damage] = []
	var damage_queue: Array[Damage] = DamageManager.damage_queue
	var head_index: int = 0
	while head_index < damage_queue.size():
		var damage: Damage = damage_queue[head_index]
		damage_queue[head_index] = null
		head_index += 1
		
		var target: Entity = EntityManager.get_entity_by_id(damage.target_id)
		if not target:
			continue

		if target.state & Entity.State.DEAD:
			continue

		var health_c: HealthComponent = target.get_node_or_null(Constants.HEALTH_COMPONENT_NODE_PATH)
		if not health_c:
			continue
			
		var health_c_config: HealthComponentNodeConfig = health_c.config
		var source: Entity = EntityManager.get_entity_by_id(damage.source_id)
		var source_name: StringName = damage.source_name

		var dodge_c: DodgeComponent = target.get_node_or_null(Constants.DODGE_COMPONENT_NODE_PATH)
		if dodge_c:
			if dodge_c.select_skill(target, damage, source):
				target.state |= Entity.State.DODGE
				if target.state & Entity.State.WAITING:
					target.state |= Entity.State.INTERRUPT_WAIT
				continue

		if target.state & Entity.State.DODGE:
			continue
				
		if damage.damage_type & health_c_config.immuned:
			continue
			
		var actual_damage: float = Damage.predict_damage(damage.damage_type, damage.value, target)
		health_c.hp -= actual_damage
		
		if not damage.damage_flags & Damage.Flag.NO_SPIKED:
			if Utils.is_valid_number(health_c_config.spiked) and source and source.get_node_or_null(Constants.HEALTH_COMPONENT_NODE_PATH):
				var spiked_value: float = damage.value * health_c_config.spiked
				
				var bad_damage := Damage.new()
				bad_damage.target_id = source.id
				bad_damage.source_id = target.id
				bad_damage.source_name = target.name
				bad_damage.value = spiked_value
				bad_damage.damage_type = Damage.Type.TRUE
				bad_damage.damage_flags = Damage.Flag.NO_SPIKED
				# 在下一帧中处理反伤，避免循环反伤。
				new_damage_queue.append(bad_damage)
			
		Log.verbose(
			"造成伤害: 目标: %s，来源: %s，值: %s"
			% [
				target,
				source_name,
				actual_damage
			]
		)

		var damage_number := DamageNumber.new()
		damage_number.value = actual_damage
		damage_number.damage_type = damage.damage_type
		var from: Vector2 = target.global_position
		var offset_c: OffsetComponent = target.get_node_or_null(Constants.OFFSET_COMPONENT_NODE_PATH)
		if offset_c and offset_c.config.hit_offsets:
			from += offset_c.config.hit_offsets.get_offset_toward_point(
				target.global_position, target.facing_global_position
			)
		damage_number.global_position = from
		add_child(damage_number)
		
		if health_c.hp <= 0:
			_death(damage, target, health_c, source)

	DamageManager.damage_queue = new_damage_queue


## 处理死亡。
func _death(damage: Damage, target: Entity, health_c: HealthComponent, _source: Entity) -> void:
	var health_c_config: HealthComponentNodeConfig = health_c.config
	var damage_flags: int = damage.damage_flags
			
	if damage_flags & Damage.Flag.NOT_KILL:
		health_c.hp = 1
		return

	health_c.health_bar.visible = false
	target.state |= Entity.State.DEAD
	if target.state & Entity.State.WAITING:
		target.state |= Entity.State.INTERRUPT_WAIT
	GameManager.cash += health_c_config.death_gold

	if damage_flags & Damage.Flag.KILL_REMOVE:
		EntityManager.queue_remove_entity(target)
	
	await get_tree().physics_frame

	target.state &= ~Entity.State.INTERRUPT_WAIT
	AudioManager.play_sfx(health_c_config.death_sfx)
	var death_animation: FacingAnimationSet = health_c_config.death_animation
	if death_animation:
		var animated_sprite_c: AnimatedSpriteComponent = target.get_node_or_null(Constants.ANIMATED_SPRITE_COMPONENT_NODE_PATH)
		animated_sprite_c.play_animation(target, death_animation, &"death")
		if await animated_sprite_c.y_wait_animation(target, death_animation):
			return

	await target.y_wait(health_c_config.death_remove_delay)

	EntityManager.queue_remove_entity(target)
