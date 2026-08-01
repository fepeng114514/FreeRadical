extends Label


func _ready() -> void:
	WaveMgr.release_wave.connect(_on_release_wave)
	
	text = "0/%d" % WaveMgr.get_wave_count()
	
	
func _on_release_wave(wave_idx: int) -> void:
	text = "%d/%d" % [wave_idx + 1, WaveMgr.get_wave_count()]
