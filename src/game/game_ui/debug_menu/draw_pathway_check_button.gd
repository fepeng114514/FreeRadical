extends CheckButton


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	PathwayMgr.is_draw_pathway = button_pressed
