extends Label


func _ready() -> void:
	WaveManager.wave_sended.connect(_on_wave_sended)
	
	text = "0/%d" % WaveManager.wave_group.wave_list.size()
	
	
func _on_wave_sended(wave_index: int) -> void:
	text = "%d/%d" % [wave_index + 1, WaveManager.wave_group.wave_list.size()]
