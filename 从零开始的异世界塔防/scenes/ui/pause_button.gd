extends Button
@onready var speed_button: Button = $"../SpeedButton"

var is_pause: bool = false

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		is_pause = not is_pause
		
		if is_pause:
			Engine.time_scale = 0
			speed_button.curren_time_scale_idx = 0
			speed_button.text = "0.0x"
		else:
			Engine.time_scale = 1
			speed_button.curren_time_scale_idx = 2
			speed_button.text = "1.0x"
