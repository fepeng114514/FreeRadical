extends Label


func _ready() -> void:
	WaveManager.wave_released.connect(_on_release_wave)
	
	text = "0/%d" % WaveManager.wave_group.wave_list.size()
	
	
func _on_release_wave(wave_index: int) -> void:
	text = "%d/%d" % [wave_index + 1, WaveManager.wave_group.wave_list.size()]
