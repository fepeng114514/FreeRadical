extends BulletTrajectory
class_name LinearBulletTrajectory
## 直线轨迹。
##
## 负责处理子弹沿直线从起点飞向目标点。


## 子弹从发射到命中或消失的时间。
@export var flight_total_time: float = 0.0


func _get_predict_time() -> float:
	return flight_total_time


func _init_trajectory(bullet_c: BulletComponent, _e: Entity, _target: Entity) -> void:
	bullet_c.velocity = U.initial_linear_velocity(
		bullet_c.from, bullet_c.to, flight_total_time
	)


func _update_trajectory(e: Entity, bullet_c: BulletComponent, _target: Entity, flying_time: float, _delta: float) -> void:
	e.global_position = U.position_in_linear(
		bullet_c.velocity, bullet_c.from, flying_time
	)


func _can_miss(e: Entity, bullet_c: BulletComponent, flying_time: float) -> bool:
	return (
		flying_time >= flight_total_time
		or super(e, bullet_c, flying_time)
	)
