extends DebugMenuEditButton


func _ready() -> void:
	pressed.connect(_on_pressed)
	

func _on_pressed() -> void:
	var value := int(line_edit.text)

	GameMgr.life += value
		
	
