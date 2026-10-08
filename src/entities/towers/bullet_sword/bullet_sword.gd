@tool
extends Entity

@onready var bullet_c = get_node_or_null(Constants.BULLET_COMPONENT_NODE_PATH)
var stay_height: int = 0
var stay_time: float = 0.0
var to_predict_time: float = 0.0
var is_stay: bool = true
var is_to_predict: bool = true
var has_to_predict: bool = false
var has_init_fall: bool = false


func _on_insert() -> bool:
	global_position.y -= stay_height

	return true


func _on_update(_delta: float) -> void:
	var target: Entity = EntityManager.get_entity_by_id(target_id)

	# 停留状态
	if target and is_stay and not TimeManager.has_elapsed(bullet_c.timestamp, stay_time):
		var t_pos: Vector2 = target.global_position
		global_position = Vector2(t_pos.x, t_pos.y - stay_height)
		bullet_c.to = global_position
		bullet_c.from = global_position
		return
	
	# 初始化预判位置
	if not has_to_predict:
		is_stay = false
		has_to_predict = true
		
		if is_instance_valid(target):
			var bullet_c_config: BulletComponentNodeConfig = bullet_c.config
			var predict_time: float = (
				bullet_c_config.trajectory.flight_total_time
				if bullet_c_config.trajectory and "flight_total_time" in bullet_c_config.trajectory
				else 0.0
			)
			bullet_c.predicted_target_global_position = PathwayManager.predict_target_global_position(
				target, (predict_time + to_predict_time)
			)
		else:
			bullet_c.predicted_target_global_position = Vector2(
				bullet_c.to.x, bullet_c.to.y + stay_height
			)
		bullet_c.to = bullet_c.predicted_target_global_position
		
		bullet_c.velocity = MathUtils.initial_linear_velocity(
			global_position, 
			Vector2(bullet_c.to.x, bullet_c.to.y - stay_height), 
			to_predict_time
		)
		bullet_c.timestamp = TimeManager.tick_timestamp
		
	# 飞向预判位置
	if is_to_predict and not TimeManager.has_elapsed(bullet_c.timestamp, to_predict_time):
		global_position = MathUtils.position_in_linear(
			bullet_c.velocity, bullet_c.from, TimeManager.get_elapsed_time(bullet_c.timestamp)
		)
		
		return
	
	# 初始化下落
	if not has_init_fall:
		is_to_predict = false
		has_init_fall = true
		bullet_c.from = global_position

		var fall_time: float = (
			bullet_c.trajectory.flight_total_time
			if bullet_c.trajectory and "flight_total_time" in bullet_c.trajectory
			else 0.0
		)
		bullet_c.velocity = MathUtils.initial_linear_velocity(
			global_position, bullet_c.to, fall_time
		)

		bullet_c.timestamp = TimeManager.tick_timestamp

	# 下落
	global_position = MathUtils.position_in_linear(
		bullet_c.velocity, bullet_c.from, TimeManager.get_elapsed_time(bullet_c.timestamp)
	)
