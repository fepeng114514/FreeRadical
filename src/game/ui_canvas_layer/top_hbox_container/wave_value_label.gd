extends Label


func _ready() -> void:
	WaveManager.release_wave.connect(_on_release_wave)
	
	text = "0/%d" % WaveManager.get_wave_count()
	
	
func _on_release_wave(wave_index: int) -> void:
	text = "%d/%d" % [wave_index + 1, WaveManager.get_wave_count()]
