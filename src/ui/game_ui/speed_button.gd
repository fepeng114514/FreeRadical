extends Button


const TIME_SCALES = [
	0,
	0.5,
	1,
	2,
]

var curren_time_scale_idx: int = 2


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	curren_time_scale_idx += 1
	curren_time_scale_idx %= TIME_SCALES.size()
	
	var time_scale: float = TIME_SCALES[curren_time_scale_idx]
	Engine.time_scale = time_scale
	text = "%.1fx" % time_scale
