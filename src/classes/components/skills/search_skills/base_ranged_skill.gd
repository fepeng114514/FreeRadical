@abstract
@tool
extends SearchSkill
class_name BaseRangedSkill
## 远程技能节点基类。
##
## BaseRangedSkill 是一个抽象类，用于定义远程技能节点的基类。它会生成一个子弹，以子弹作为中介，对目标造成影响。子弹会以特定轨迹飞行，到达目标后造成影响。


## 子弹生成模式枚举。
enum BulletSpawnMode {
	## 子弹生成模式：随机，子弹会以 [member bullet_angle_range] 范围内的随机角度生成。
	RANDOM,
	## 子弹生成模式：等距，子弹会以 [member bullet_angle_range] 范围内等距的角度生成。
	EQUAL_INTERVAL,
}


## 生成子弹。
func _spawn_bullets(
		entity: Entity, 
		target: Entity,
		config: RangedSkillNodeConfig
	) -> void:
	var entity_to_target_angle: float = entity.global_position.angle_to_point(target.global_position)
	var half_angle_range: float = config.bullet_angle_range / 2
	var da: float = (config.bullet_angle_range) / config.bullet_count + 1
	
	for bullet_index: int in config.bullet_count:
		var bullet = EntityManager.create_entity(config.bullet_scene)
		bullet.target_id = target.id
		bullet.source_id = entity.id

		var bullet_rotation: float = 0.0
		match config.bullet_spawn_mode:
			BulletSpawnMode.EQUAL_INTERVAL:
				bullet_rotation = entity_to_target_angle + (da * bullet_index + -half_angle_range)
			BulletSpawnMode.RANDOM:
				var random_angle: float = randf_range(
					-half_angle_range, half_angle_range	
				)
				bullet_rotation = entity_to_target_angle + random_angle
				
		bullet.rotation = bullet_rotation
		var bullet_global_position: Vector2 = entity.global_position
		if config.bullet_offsets:
			var offset: Vector2 = config.bullet_offsets.get_offset_toward_point(
				entity.global_position, entity.facing_global_position
			)
			bullet_global_position += offset
		bullet.global_position = bullet_global_position

		EntityManager.queue_insert_entity(bullet)
