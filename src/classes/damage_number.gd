extends Label
class_name DamageNumber
## 伤害数字资源。


## 伤害数字数据字典，键为伤害值范围，值为伤害数字的缩放比例和移动时间。
const value_range_data_dict: Dictionary[Array, Dictionary] = {
	[0, 15]: { 
		"scale": 0.2, 
		"time": 0.5,
		"speed": 100,
	},
	[16, 30]: { 
		"scale": 0.225, 
		"time": 0.6,
		"speed": 83,
	},
	[31, 50]: { 
		"scale": 0.25, 
		"time": 0.7,
		"speed": 71,
	},
	[51, 90]: { 
		"scale": 0.275, 
		"time": 0.8,
		"speed": 62,
	},
	[91, INF]: { 
		"scale": 0.3, 
		"time": 0.9,
		"speed": 55,
	},
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
var move_speed: float = 100.0
## 移动时间戳。
var move_ts: float = 0.0


func _ready() -> void:
	text = "%d" % value

	for value_range: Array in value_range_data_dict:
		var min_range: float = value_range[0]
		var max_range: float = value_range[1]
		if value >= min_range and value <= max_range:
			var s: float = value_range_data_dict[value_range].scale
			target_scale = Vector2(s, s)
			move_total_time = value_range_data_dict[value_range].time
			move_speed = value_range_data_dict[value_range].speed
			break

	if damage_type & C.DamageType.PHYSICAL:
		modulate = Color.WHITE
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


func _process(delta: float) -> void:
	move_ts += delta
	
	global_position += Vector2(0, -move_speed) * delta
	
	if move_ts >= move_total_time:
		queue_free()
	
