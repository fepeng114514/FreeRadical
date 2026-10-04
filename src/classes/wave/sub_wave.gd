extends WaveBase
class_name SubWave
## 子波次资源。


## 索引。
@export var index: int = 0
## 延迟（秒）。
@export var delay: float = 0.0
## 生成组列表。
@export var spawn_list: Array[WaveSpawn] = []

## 生成组队列。
var spawn_queue: Array[WaveSpawn] = []
## 是否完成。
var is_finished: bool = false