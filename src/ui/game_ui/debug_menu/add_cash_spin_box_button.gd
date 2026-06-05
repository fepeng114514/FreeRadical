@tool
extends SpinBoxButton


func _ready() -> void:
	button.pressed.connect(_on_pressed)
	

func _on_pressed() -> void:
	var v: float = spin_box.value

	GameMgr.cash += v
		
	
