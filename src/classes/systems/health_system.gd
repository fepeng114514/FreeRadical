extends System
class_name HealthSystem
## 血量系统。
##
## HealthSystem 负责处理拥有 [HealthComponent] 血量组件的实体，包括回血等。


func _on_insert(entity: Entity) -> bool:
	var health_c: HealthComponent = entity.get_node_or_null(Constants.HEALTH_COMPONENT_NODE_PATH)
	if not health_c:
		return true
		
	health_c.hp = health_c.config.hp_max
	
	return true


func _on_update(_delta: float) -> void:
	for entity: Entity in EntityManager.get_component_entity_group(Constants.HEALTH_COMPONENT_NAME):
		if entity.state & Entity.State.DEAD:
			continue

		var health_c: HealthComponent = entity.get_node_or_null(Constants.HEALTH_COMPONENT_NODE_PATH)

		_process_regen(entity, health_c)
		_process_doomed_state(entity, health_c)


## 处理回血。
func _process_regen(entity: Entity, health_c: HealthComponent) -> void:
	if health_c.config.regen_hp != 0:
		if TimeManager.has_elapsed(health_c.regen_time_stamp, health_c.config.regen_cooldown):	
			health_c.hp += health_c.config.regen_hp
			health_c.regen_time_stamp = TimeManager.tick_time_stamp
		
	if health_c.config.idle_regen_hp != 0 and entity.state & Entity.State.IDLE:
		if TimeManager.has_elapsed(health_c.idle_regen_time_stamp, health_c.config.idle_regen_cooldown):
			health_c.hp += health_c.config.idle_regen_hp
			health_c.idle_regen_time_stamp = TimeManager.tick_time_stamp


## 处理注定死亡状态。
func _process_doomed_state(entity: Entity, health_c: HealthComponent) -> void:
	if entity.meta_state & Entity.MetaState.DOOMED:
		return

	if health_c.hp != health_c.last_hp:
		health_c.last_hp = health_c.hp
		if _is_doomed(entity, health_c):
			entity.meta_state |= Entity.MetaState.DOOMED
		return
	
	if entity.has_new_aimed_bullet:
		entity.has_new_aimed_bullet = false

		if _is_doomed(entity, health_c):
			entity.meta_state |= Entity.MetaState.DOOMED


## 检查实体是否注定死亡。
func _is_doomed(entity: Entity, health_c: HealthComponent) -> bool:
	var total_damage: float = 0.0

	for bullet_id: int in entity.aimed_bullet_ids:
		var bullet: Entity = EntityManager.get_entity_by_id(bullet_id)
		var bullet_c: BulletComponent = bullet.get_node_or_null(Constants.BULLET_COMPONENT_NODE_PATH)
		if not bullet_c:
			continue

		var damage_influence := bullet_c.config.hit_influence as DamageInfluence
		if not damage_influence:
			continue

		if damage_influence.get_value_mode != Influence.GetValueMode.RANDOM:
			continue
		
		var actual_damage: float = Damage.predict_damage(damage_influence.damage_type, damage_influence.value, entity)
		total_damage += actual_damage
		if total_damage >= health_c.hp:
			return true

	return false
