extends WaveStateBase
class_name WaveSpawnState


var spawn: WaveSpawn = null
var need_wait_interval: bool = true
## 已生成的实体总数量
var spawned_total_count: int = 0
var is_finished: bool = false


func _init(p_spawn: WaveSpawn) -> void:
    spawn = p_spawn
