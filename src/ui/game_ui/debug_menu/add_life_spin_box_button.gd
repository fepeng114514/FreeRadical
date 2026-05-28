extends SpinBoxButton


func _ready() -> void:
	button.pressed.connect(_on_pressed)
	

func _on_pressed() -> void:
	var value := int(spin_box.value)

	GameMgr.life += value
		
	
