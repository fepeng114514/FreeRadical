extends BulletTrajectory
class_name TrackBulletTrajectory
## 追踪轨迹。
##
## [TrackBulletTrajectory] 让子弹持续追踪目标。


## 子弹的飞行速度。
@export var flight_speed: float = 0.0


func _init_trajectory(bullet: Entity, bullet_c: BulletComponent, _target: Entity) -> void:
	if bullet_c.config.facing_enabled:
		bullet.look_at(bullet_c.to)


func _update_trajectory(bullet: Entity, bullet_c: BulletComponent, target: Entity, _flying_time: float, _delta: float) -> void:
	if is_instance_valid(target):
		var to: Vector2 = target.global_position
		var offset_c: OffsetComponent = target.get_node_or_null(Constants.OFFSET_COMPONENT_NODE_PATH)
		if offset_c and offset_c.config.hit_offsets:
			to += offset_c.config.hit_offsets.get_offset_toward_point(
				target.global_position, target.facing_global_position
			)
		bullet_c.to = to

	var direction: Vector2 = bullet.global_position.direction_to(bullet_c.to)
	bullet.global_position += direction * flight_speed * TimeManager.frame_length

	if bullet_c.config.facing_enabled:
		bullet.look_at(bullet_c.to)
