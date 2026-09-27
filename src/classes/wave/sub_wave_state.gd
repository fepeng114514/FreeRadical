extends WaveStateBase
class_name SubWaveState


var sub_wave: SubWave = null
var spawn_queue: Array[WaveSpawnState] = []
var is_finished: bool = false


func _init(p_sub_wave: SubWave) -> void:
    sub_wave = p_sub_wave
