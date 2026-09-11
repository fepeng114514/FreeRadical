extends Label


func _ready() -> void:
	GameManager.cash_changed.connect(_on_cash_changed)


func _on_cash_changed(new_cash: float) -> void:
	text = "%d" % new_cash
	
	
