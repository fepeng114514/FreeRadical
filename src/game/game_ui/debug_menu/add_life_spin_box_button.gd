@tool
extends SpinBoxButton


func _ready() -> void:
	super()
	button.pressed.connect(_on_pressed)
	

func _on_pressed() -> void:
	var v := int(spin_box.value)

	GameMgr.life += v
		
	
