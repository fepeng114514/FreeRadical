extends CheckButton


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	PathwayManager.is_draw_pathway = button_pressed
