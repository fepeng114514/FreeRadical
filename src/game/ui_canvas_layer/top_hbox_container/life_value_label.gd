extends Label


func _ready() -> void:
	GameMgr.life_changed.connect(_on_life_changed)
	
	
func _on_life_changed(new_life: int) -> void:
	text = "%d" % new_life
