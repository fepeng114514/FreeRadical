extends Resource
class_name Wave
## 波次资源。


## 波次间隔（秒）。
@export var interval: float = 30.0
## 子波次列表。
@export var sub_wave_list: Array[SubWave] = []
