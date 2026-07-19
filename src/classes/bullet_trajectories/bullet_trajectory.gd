@abstract
extends Resource
class_name BulletTrajectory
## 子弹轨迹基类。
##
## 每种轨迹类型继承此类，实现各自的初始化与更新逻辑。


func _init() -> void:
	resource_local_to_scene = true


@warning_ignore_start("unused_parameter")
## 子弹创建时调用，初始化子弹的轨迹参数。
func _init_trajectory(bullet_c: BulletComponent, e: Entity, target: Entity) -> void:
	pass


## 每帧调用，更新子弹的位置。
func _update_trajectory(e: Entity, bullet_c: BulletComponent, target: Entity, flying_time: float, delta: float) -> void:
	pass


## 预判目标位置时使用的飞行时间（默认 0 表示当前时刻的位置）
func _get_predict_time() -> float:
	return 0.0


## 子弹是否可以未命中目标实体。
func _can_miss(e: Entity, bullet_c: BulletComponent, flying_time: float) -> bool:
	return U.is_at_destination(e.global_position, bullet_c.to, bullet_c.hit_distance)


## 子弹是否可以命中目标实体。
func _can_hit(e: Entity, bullet_c: BulletComponent, flying_time: float) -> bool:
	return U.is_at_destination(e.global_position, bullet_c.to, bullet_c.hit_distance)
@warning_ignore_restore("unused_parameter")
