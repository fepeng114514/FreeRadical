extends Resource
class_name WaveGroup
## 波次组资源。


## 波次列表。
@export var wave_list: Array[Wave] = []


func _init() -> void:
	resource_local_to_scene = true