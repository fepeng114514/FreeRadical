extends Label
class_name DamageNumber
## 伤害数字节点。
## 
## [DamageNumber] 用于在游戏中显示伤害值。


## 伤害数字数据映射表，键为伤害值范围，值为伤害数字的缩放比例和移动时间。
const VALUE_RANGE_TO_DATA_MAP: Dictionary[Array, Dictionary] = {
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
var damage_type: int = Damage.Type.NONE
## 伤害值。
var value: float = 0.0
## 缩放持续时间。
var _scale_duration: float = 0.2
## 目标的缩放比例。
var _target_scale := Vector2.ZERO
## 移动总时间。
var _move_total_time: float = 0.0
## 移动速度。
var _move_speed: float = 100.0
## 移动时间戳。
var _move_timestamp: float = 0.0


func _ready() -> void:
	text = "%d" % value

	for value_range: Array in VALUE_RANGE_TO_DATA_MAP:
		var min_range: float = value_range[0]
		var max_range: float = value_range[1]
		if value < min_range or value > max_range:
			continue

		var s: float = VALUE_RANGE_TO_DATA_MAP[value_range].scale
		_target_scale = Vector2(s, s)
		_move_total_time = VALUE_RANGE_TO_DATA_MAP[value_range].time
		_move_speed = VALUE_RANGE_TO_DATA_MAP[value_range].speed
		break

	if damage_type & Damage.Type.PHYSICAL:
		modulate = Color.WHITE
	elif damage_type & Damage.Type.MAGICAL:
		modulate = Color.SKY_BLUE
	elif damage_type & Damage.Type.EXPLOSION:
		modulate = Color.RED
	elif damage_type & Damage.Type.MAGICAL_EXPLOSION:
		modulate = Color.BLUE
	elif damage_type & Damage.Type.TRUE:
		modulate = Color.GOLD
	else:
		modulate = Color(0.5, 1, 0.5, 1)

	scale = Vector2(0, 0)
	add_theme_font_size_override("font_size", 100)

	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", _target_scale, _scale_duration)


func _process(delta: float) -> void:
	_move_timestamp += delta
	global_position += Vector2(0, -_move_speed) * delta
	
	if _move_timestamp >= _move_total_time:
		queue_free()
	
