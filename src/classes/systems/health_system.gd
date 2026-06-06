extends System
class_name HealthSystem
## 血量系统
##
## 处理拥有 [HealthComponent] 血量组件的实体


func _on_insert(e: Entity) -> bool:
	var health_c: HealthComponent = e.get_node_or_null(C.CN_HEALTH)
	if not health_c:
		return true
		
	health_c.hp = health_c.hp_max
	
	return true


func _on_update(_delta: float) -> void:
	for e: Entity in EntityMgr.get_entities_group(C.CN_HEALTH):
		var health_c: HealthComponent = e.get_node_or_null(C.CN_HEALTH)
		
		if e.state & Entity.State.DEAD:
			if e._on_death():
				return
		
			AudioMgr.play_sfx(health_c.death_sfx)
			var death_animation: AnimationGroup = health_c.death_animation
			if death_animation:
				e.play_animation(death_animation, &"death")
				if await e.y_wait_animation(death_animation):
					return

			e.remove_entity()

		if health_c.regen_hp != 0:
			if TimeMgr.is_ready_time(health_c.regen_ts, health_c.regen_cooldown):
				health_c.hp += health_c.regen_hp
				health_c.regen_ts = TimeMgr.tick_ts
		
		if health_c.idle_regen_hp != 0:
			if e.state & Entity.State.IDLE:
				if TimeMgr.is_ready_time(health_c.idle_regen_ts, health_c.idle_regen_cooldown):
					health_c.hp += health_c.idle_regen_hp
					health_c.idle_regen_ts = TimeMgr.tick_ts
