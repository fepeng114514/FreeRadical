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
	var entities: Array = EntityMgr.get_entities_group(C.CN_HEALTH).filter(
		func(e: Entity) -> bool:
			return not e.state & Entity.State.DEATH
	)
	
	for e: Entity in entities:
		var health_c: HealthComponent = e.get_node_or_null(C.CN_HEALTH)

		if health_c.regen_hp != 0:
			if TimeMgr.is_ready_time(health_c.regen_ts, health_c.regen_cooldown):
				health_c.hp += health_c.regen_hp
				health_c.regen_ts = TimeMgr.tick_ts
		
		if health_c.idle_regen_hp != 0:
			if e.state & Entity.State.IDLE:
				if TimeMgr.is_ready_time(health_c.idle_regen_ts, health_c.idle_regen_cooldown):
					health_c.hp += health_c.idle_regen_hp
					health_c.idle_regen_ts = TimeMgr.tick_ts
