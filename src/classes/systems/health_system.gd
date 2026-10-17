extends System
class_name HealthSystem
## 血量系统。
##
## [HealthSystem] 负责处理拥有 [HealthComponent] 的实体。


func _on_insert(entity: Entity) -> bool:
	var health_c: HealthComponent = entity.get_node_or_null(Constants.HEALTH_COMPONENT_NODE_PATH)
	if not health_c:
		return true
		
	health_c.hp = health_c.config.hp_max
	
	return true


func _on_update(_delta: float) -> void:
	for entity: Entity in EntityManager.get_component_entity_group(Enums.ComponentFlag.HEALTH):
		if entity.state & Entity.State.DEAD:
			continue

		var health_c: HealthComponent = entity.get_node_or_null(Constants.HEALTH_COMPONENT_NODE_PATH)

		_process_regen(entity, health_c)
		_update_total_pending_damage(entity, health_c)


## 处理回血。
func _process_regen(entity: Entity, health_c: HealthComponent) -> void:
	var health_c_config: HealthComponentNodeConfig = health_c.config
	if health_c_config.regen_hp != 0:
		if TimeManager.has_elapsed(health_c.regen_timestamp, health_c_config.regen_cooldown):	
			health_c.hp += health_c_config.regen_hp
			health_c.regen_timestamp = TimeManager.tick_timestamp
		
	if health_c_config.idle_regen_hp != 0 and entity.state & Entity.State.IDLE:
		if TimeManager.has_elapsed(health_c.idle_regen_timestamp, health_c_config.idle_regen_cooldown):
			health_c.hp += health_c_config.idle_regen_hp
			health_c.idle_regen_timestamp = TimeManager.tick_timestamp


## 更新待定总伤害。
func _update_total_pending_damage(entity: Entity, health_c: HealthComponent) -> void:
	if not entity.is_aimed_bullet_ids_changed:
		return

	entity.is_aimed_bullet_ids_changed = false

	var total_damage: float = 0.0
	for bullet_id: int in entity.aimed_bullet_ids:
		var bullet: Entity = EntityManager.get_entity_by_id(bullet_id)
		var bullet_c: BulletComponent = bullet.get_node_or_null(Constants.BULLET_COMPONENT_NODE_PATH)
		if not bullet_c:
			continue

		var damage_influence := bullet_c.config.influence as DamageInfluence
		if not damage_influence:
			continue

		if damage_influence.get_value_mode != Influence.GetValueMode.RANDOM:
			continue
		
		var actual_damage: float = Damage.predict_damage(damage_influence.damage_type, damage_influence.value, entity)
		total_damage += actual_damage

	health_c.total_pending_damage_value = total_damage
