extends WaveStateBase
class_name WaveState


var wave: Wave = null
var sub_wave_queue: Array[SubWaveState] = []


func _init(p_wave: Wave) -> void:
    wave = p_wave
