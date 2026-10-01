extends BulletTrajectory
class_name ParabolaBulletTrajectory
## 抛物线轨迹。
##
## 负责处理子弹沿抛物线从起点飞向目标点。


## 子弹从发射到命中或消失的时间。
@export var flight_total_time: float = 0.0
## 重力加速度。
@export var flight_gravity: float = 980.0
## 检查到达目标点的时间阈值。
@export var arrival_time_threshold_factor: float = 0.8


func _get_predict_time() -> float:
	return flight_total_time


func _init_trajectory(bullet: Entity, bullet_c: BulletComponent, _target: Entity) -> void:
	var from: Vector2 = bullet_c.from
	var to: Vector2 = bullet_c.to

	var velocity: Vector2 = MathUtils.initial_parabola_velocity(
		from, to, flight_total_time, flight_gravity
	)
	bullet_c.velocity = velocity

	var next_global_position: Vector2 = MathUtils.get_position_in_parabola(
		velocity, from, 0.1, flight_gravity
	)

	if bullet_c.config.facing_enabled:
		bullet.look_at(next_global_position)


func _update_trajectory(bullet: Entity, bullet_c: BulletComponent, _target: Entity, flying_time: float, _delta: float) -> void:
	var next_global_position: Vector2 = MathUtils.get_position_in_parabola(
		bullet_c.velocity, bullet_c.from, flying_time, flight_gravity
	)
	bullet.global_position = next_global_position

	var next_time: float = flying_time + TimeManager.frame_length
	next_global_position = MathUtils.get_position_in_parabola(
		bullet_c.velocity, bullet_c.from, next_time, flight_gravity
	)
	if bullet_c.config.facing_enabled:
		bullet.look_at(next_global_position)


func _can_miss(bullet: Entity, bullet_c: BulletComponent, flying_time: float) -> bool:
	return (
		flight_total_time > 0 and flying_time >= flight_total_time
		or super(bullet, bullet_c, flying_time)
	)


func _can_hit(bullet: Entity, bullet_c: BulletComponent, flying_time: float) -> bool:
	return (
		flying_time >= flight_total_time * arrival_time_threshold_factor
		and super(bullet, bullet_c, flying_time)
	)
