extends Button


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	WaveManager.is_skip_wave = true
	WaveManager.is_release_wave = true
