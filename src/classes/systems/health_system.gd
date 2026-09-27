extends ECSSystem
class_name HealthSystem
## 血量系统。
##
## HealthSystem 负责处理拥有 [HealthComponent] 血量组件的实体，包括回血等。


func _on_insert(entity: ECSEntity) -> bool:
	entity = entity as Entity
	
	var health_c: HealthComponent = entity.get_node_or_null(Constants.CN_HEALTH)
	if not health_c:
		return true
		
	health_c.hp = health_c.hp_max
	
	return true


func _on_update(_delta: float) -> void:
	for entity: Entity in ECSEntityManager.get_component_entity_group(Constants.CN_HEALTH):
		if entity.state & Entity.State.DEAD:
			continue

		var health_c: HealthComponent = entity.get_node_or_null(Constants.CN_HEALTH)

		if health_c.regen_hp != 0:
			if TimeManager.has_elapsed(health_c.regen_time_stamp, health_c.regen_cooldown):
				health_c.hp += health_c.regen_hp
				health_c.regen_time_stamp = TimeManager.tick_time_stamp
		
		if health_c.idle_regen_hp != 0:
			if entity.state & Entity.State.IDLE:
				if TimeManager.has_elapsed(health_c.idle_regen_time_stamp, health_c.idle_regen_cooldown):
					health_c.hp += health_c.idle_regen_hp
					health_c.idle_regen_time_stamp = TimeManager.tick_time_stamp
