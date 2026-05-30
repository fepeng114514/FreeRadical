extends Button


@export var search_combo_box: SearchComboBox = null

@onready var popup: Popup = search_combo_box.popup


func _ready() -> void:
	pressed.connect(_on_pressed)
	
	
func _on_pressed() -> void:
	popup.visible = not popup.visible
	
	var x := int(global_position.x - popup.size.x + size.x)
	var y := int(global_position.y + size.y)
	popup.position = Vector2i(x, y)
