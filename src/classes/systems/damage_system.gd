extends ECSSystem
class_name DamageSystem
## 伤害系统。
##
## DamageSystem 负责处理伤害队列的伤害造成。


func _on_update(_delta: float) -> void:
	var new_damage_queue: Array[Damage] = []
	var damage_queue: Array[Damage] = DamageManager.damage_queue
	
	while damage_queue:
		var damage: Damage = damage_queue.pop_front()
		
		var target: Entity = ECSEntityManager.get_entity_by_id(damage.target_id)
		if not target:
			continue

		if target.state & Entity.State.DEAD:
			continue

		var health_c: HealthComponent = target.get_node_or_null(Constants.CN_HEALTH)
		if not health_c:
			continue
			
		var source: Entity = ECSEntityManager.get_entity_by_id(damage.source_id)
		var source_name: StringName = damage.source_name

		var dodge_c: DodgeComponent = target.get_node_or_null(Constants.CN_DODGE)
		if dodge_c:
			if dodge_c.select_skill(target, damage, source):
				target.state |= Entity.State.DODGE
				if target.state & Entity.State.WAITING:
					target.state |= Entity.State.INTERRUPT_WAIT
				continue

		if target.state & Entity.State.DODGE:
			continue
				
		if damage.damage_type & health_c.immuned:
			continue
			
		var actual_damage: float = damage.predict_damage(target)
		health_c.hp -= actual_damage
		target._on_damage(damage)
		
		if not damage.damage_flags & Damage.Flag.NO_SPIKED:
			if Utils.is_valid_number(health_c.spiked) and source and source.get_node_or_null(Constants.CN_HEALTH):
				var spiked_value: float = damage.value * health_c.spiked
				
				var bad_damage := Damage.new()
				bad_damage.target_id = source.id
				bad_damage.source_id = target.id
				bad_damage.source_name = target.name
				bad_damage.value = spiked_value
				bad_damage.damage_type = Damage.Type.TRUE
				bad_damage.damage_flags = Damage.Flag.NO_SPIKED
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
		if target.hit_offsets:
			var hit_offset: Vector2 = target.hit_offsets.get_offset_toward_point(
				target.global_position, target.facing_global_position
			)
			from += hit_offset
		damage_number.global_position = from
		
		add_child(damage_number)
		
		if health_c.hp <= 0:
			_death(damage, target, health_c, source)

	DamageManager.damage_queue = new_damage_queue
	

## 死亡处理。
func _death(damage: Damage, target: Entity, health_c: HealthComponent, source: Entity) -> void:
	var damage_flags: int = damage.damage_flags
			
	if damage_flags & Damage.Flag.NOT_KILL:
		health_c.hp = 1
		return
	
	var killer: Entity = source
	while killer:
		killer._on_kill(target)
		
		killer = ECSEntityManager.get_entity_by_id(killer.source_id)

	health_c.health_bar.visible = false
	target.state |= Entity.State.DEAD
	if target.state & Entity.State.WAITING:
		target.state |= Entity.State.INTERRUPT_WAIT
	GameManager.cash += health_c.death_gold

	if damage_flags & Damage.Flag.KILL_REMOVE:
		ECSEntityManager.queue_remove_entity(target)
	
	await get_tree().physics_frame

	if target._on_death():
		return

	AudioManager.play_sfx(health_c.death_sfx)
	target.state &= ~Entity.State.INTERRUPT_WAIT
	var death_animation: AnimationGroup = health_c.death_animation
	if death_animation:
		target.play_animation(death_animation, &"death")
		if await target.y_wait_animation(death_animation):
			return

	await target.y_wait(health_c.death_remove_delay)

	ECSEntityManager.queue_remove_entity(target)
