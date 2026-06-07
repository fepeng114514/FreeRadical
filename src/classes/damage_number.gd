extends Label
class_name DamageNumber
## 伤害数字资源。


## 伤害数字数据字典，键为伤害值范围，值为伤害数字的缩放比例和移动时间。
const value_range_data_dict: Dictionary[Array, Dictionary] = {
	[0, 15]: { "scale": Vector2(0.2, 0.2), "time": 0.7 },
	[16, 30]: { "scale": Vector2(0.3, 0.3), "time": 1 },
	[31, 70]: { "scale": Vector2(0.5, 0.5), "time": 1.5 },
	[71, INF]: { "scale": Vector2(0.7, 0.7), "time": 2 },
}


## 伤害类型。
var damage_type: int = C.DamageType.NONE
## 伤害值。
var value: float = 0.0
## 缩放持续时间。
var scale_duration: float = 0.2
## 目标的缩放比例。
var target_scale := Vector2.ZERO

## 移动总时间。
var move_total_time: float = 0.0
## 移动速度。
var move_velocity := Vector2.UP
## 移动时间戳。
var move_ts: float = 0.0


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


func _process(delta: float) -> void:
	move_ts += delta
	
	global_position = move_velocity * delta
	
	if move_ts >= move_total_time:
		queue_free()
	
