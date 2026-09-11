extends BulletTrajectory
class_name TrackBulletTrajectory
## 追踪轨迹。
##
## 负责处理子弹持续追踪目标，实时更新方向。


## 子弹的飞行速度。
@export var flight_speed: float = 0.0


func _init_trajectory(bullet: Entity, bullet_c: BulletComponent, _target: Entity) -> void:
	if bullet_c.facing_enabled:
		bullet.look_at(bullet_c.to)


func _update_trajectory(bullet: Entity, bullet_c: BulletComponent, target: Entity, _flying_time: float, _delta: float) -> void:
	if is_instance_valid(target):
		var to: Vector2 = target.global_position
		if target.hit_offsets:
			var hit_offset: Vector2 = target.hit_offsets.get_offset_toward_point(
				target.global_position, target.facing_global_position
			)
			to += hit_offset
		bullet_c.to = to

	var direction: Vector2 = bullet.global_position.direction_to(bullet_c.to)
	bullet.global_position += direction * flight_speed * TimeManager.frame_length

	if bullet_c.facing_enabled:
		bullet.look_at(bullet_c.to)
