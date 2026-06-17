extends Button


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	WaveMgr.is_release_wave = true
	if WaveMgr.is_first_release_wave:
		WaveMgr.is_first_release_wave = false
		WaveMgr.first_release_wave.emit()
	else:
		WaveMgr.is_skip_wave = true
