extends BulletTrajectory
class_name InstantBulletTrajectory
## 瞬移轨迹。
##
## 负责处理子弹瞬间移动到目标位置。


func _init_trajectory(bullet: Entity, _bullet_c: BulletComponent, target: Entity) -> void:
	bullet.global_position = target.global_position
	bullet.rotation = deg_to_rad(90)
