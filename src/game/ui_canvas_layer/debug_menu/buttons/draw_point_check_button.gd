extends CheckButton


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	DebugManager.draw_point_enabled = button_pressed
