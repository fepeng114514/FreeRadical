extends DebugMenuEditButton


func _ready() -> void:
	pressed.connect(_on_pressed)
	

func _on_pressed() -> void:
	var value := float(line_edit.text)

	GameMgr.cash += value
		
	
