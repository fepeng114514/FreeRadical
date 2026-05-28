extends Resource
class_name SubWave
## 子波次资源


## 生成路径
@export var pathway_idx: int = 0
## 延迟，单位为秒
@export var delay: float = 0
## 敌人生成列表
@export var spawn_list: Array[WaveSpawn] = []
