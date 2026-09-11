extends Button


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	WaveManager.is_release_wave = true
	if WaveManager.is_first_release_wave:
		WaveManager.is_first_release_wave = false
		WaveManager.first_release_wave.emit()
	else:
		WaveManager.is_skip_wave = true
