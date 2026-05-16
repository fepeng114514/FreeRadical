extends System
class_name DamageSystem
## 伤害系统
##
## 处理伤害队列的伤害造成


func _on_update(_delta: float) -> void:
	var new_damage_queue: Array[Damage] = []
	var damage_queue: Array[Damage] = SystemMgr.damage_queue
	
	while damage_queue:
		var d: Damage = damage_queue.pop_front()
		
		var target: Entity = EntityMgr.get_entity_by_id(d.target_id)
		if not target:
			continue

		var health_c: HealthComponent = target.get_node_or_null(C.CN_HEALTH)
		if not health_c:
			continue
			
		var source: Entity = EntityMgr.get_entity_by_id(d.source_id)
		var source_name: StringName = d.source_name
		
		if d.damage_type & health_c.immuned:
			continue
			
		var actual_damage: float = _predict_damage(
			target, health_c, d
		)
		health_c.hp -= actual_damage
		target._on_damage(d)
		
		if not d.damage_flags & C.DamageFlag.NO_SPIKED:
			if U.is_valid_number(health_c.spiked) and source and source.get_node_or_null(C.CN_HEALTH):
				var spiked_value: float = d.value * health_c.spiked
				
				var bad_damage := Damage.new()
				bad_damage.target_id = source.id
				bad_damage.source_id = target.id
				bad_damage.source_name = target.name
				bad_damage.value = spiked_value
				bad_damage.damage_type = C.DamageType.TRUE
				bad_damage.damage_flags = C.DamageFlag.NO_SPIKED
				new_damage_queue.append(bad_damage)
			
		Log.verbose(
			"造成伤害: 目标: %s，来源: %s，值: %s"
			% [
				target,
				source_name,
				actual_damage
			]
		)
		
		if health_c.hp <= 0:
			var damage_flags: int = d.damage_flags
			
			if damage_flags & C.DamageFlag.NOT_KILL:
				health_c.hp = 1
				return
			
			var killer: Entity = source
			while killer:
				killer._on_kill(target)
				
				killer = EntityMgr.get_entity_by_id(killer.source_id)

			health_c.health_bar.visible = false
			target.state = Entity.State.DEATH
			GameMgr.cash += health_c.death_gold

			if damage_flags & C.DamageFlag.KILL_REMOVE:
				target.remove_entity()
				return

			if target._on_death():
				return
	
			_death(target, health_c)
	
	SystemMgr.damage_queue = new_damage_queue
	

func _predict_damage(
		target: Entity,
		health_c: HealthComponent, 
		d: Damage
	) -> float:
	var damage_type: int = d.damage_type
		
	if damage_type & C.DamageType.DISINTEGRATE:
		return health_c.hp
	
	var physical_armor: float = clampf(
		U.to_percent(health_c.physical_armor), 
		0,
		1
	)
	var magical_armor: float = clampf(
		U.to_percent(health_c.magical_armor),
		0,
		1
	)
	var poison_armor: float = clampf(
		U.to_percent(health_c.poison_armor),
		0,
		1
	)
	
	var target_health_c: HealthComponent = target.get_node_or_null(C.CN_HEALTH)
	var vulnerable: float = target_health_c.vulnerable
	var resistance: float = 1 - health_c.damage_resistance

	if damage_type & C.DamageType.TRUE:
		pass
	else:
		if damage_type & C.DamageType.EXPLOSION:
			resistance *= 1 - physical_armor / 2.0
		elif damage_type & C.DamageType.PHYSICAL:
			resistance *= 1 - physical_armor
			
		if damage_type & C.DamageType.MAGICAL_EXPLOSION:
			resistance *= 1 - magical_armor / 2.0
		elif damage_type & C.DamageType.MAGICAL:
			resistance *= 1 - magical_armor
			
		if damage_type & C.DamageType.POISON:
			resistance *= 1 - poison_armor
	
	if damage_type & C.DamageType.HP_MAX_PERCENT:
		d.value *= health_c.hp_max
	elif damage_type & C.DamageType.HP_PERCENT:
		d.value *= health_c.hp
		
	var total_damage_factor: float = d.damage_factor * resistance * (1 + vulnerable)
	var basic_value: float = d.value - health_c.damage_reduction
	var actual_damage: float = roundi(basic_value * total_damage_factor)
	
	return actual_damage


func _death(e: Entity, health_c: HealthComponent) -> void:
	var death_animation: AnimationGroup = health_c.death_animation
	if death_animation:
		e.play_animation_by_look(
			death_animation, "death"
		)
		
	var death_sfx: AudioGroup = health_c.death_sfx
	if death_sfx:
		AudioMgr.play_sfx(death_sfx)
	
	await e.wait_animation(death_animation)

	e.remove_entity()
