extends Label
class_name DamageNumber


const value_range_data_dict: Dictionary[Array, Dictionary] = {
	[0, 15]: { "scale": Vector2(0.2, 0.2), "time": 0.7 },
	[16, 30]: { "scale": Vector2(0.3, 0.3), "time": 1 },
	[21, 70]: { "scale": Vector2(0.6, 0.6), "time": 1.5 },
	[71, INF]: { "scale": Vector2(0.8, 0.8), "time": 2 },
}


var damage_type: C.DamageType = C.DamageType.NONE
var value: float = 0
var scale_duration: float = 0.2
var target_scale := Vector2.ZERO

var move_total_time: float = 1
var move_from := Vector2.ZERO
var move_to := Vector2.ZERO
var move_to_radius: float = 50
var move_velocity := Vector2.ZERO
var move_gravity: float = 980
var move_ts: float = 0


func _ready() -> void:
	text = str(value)

	for value_range: Array in value_range_data_dict:
		var min_range: float = value_range[0]
		var max_range: float = value_range[1]
		if value >= min_range and value <= max_range:
			target_scale = value_range_data_dict[value_range]["scale"]
			move_total_time = value_range_data_dict[value_range]["time"]
			break

	if damage_type & C.DamageType.PHYSICAL:
		modulate = Color.GREEN
	elif damage_type & C.DamageType.MAGICAL:
		modulate = Color.SKY_BLUE
	elif damage_type & C.DamageType.EXPLOSION:
		modulate = Color.RED
	elif damage_type & C.DamageType.MAGICAL_EXPLOSION:
		modulate = Color.BLUE
	elif damage_type & C.DamageType.TRUE:
		modulate = Color.GOLD

	else:
		modulate = Color(0.5, 1, 0.5, 1)

	scale = Vector2(0, 0)
	add_theme_font_size_override("font_size", 100)

	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", target_scale, scale_duration)
	
	move_from = global_position
	move_to = U.point_on_circle(move_from, move_to_radius, randf_range(-PI, PI))
	move_velocity = U.initial_parabola_velocity(move_from, move_to, move_total_time, move_gravity)

func _physics_process(delta: float) -> void:
	move_ts += delta
	
	global_position = U.get_position_in_parabola(move_velocity, move_from, move_ts, move_gravity)
	
	if U.is_at_destination(global_position, move_to):
		queue_free()
	
