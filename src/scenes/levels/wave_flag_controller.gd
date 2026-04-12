extends Control
class_name WaveFlagController


var list: Array[WaveFlag] = []


func _ready() -> void:
	for child: Node in get_children():
		if child is not WaveFlag:
			continue
			
		list.append(child)
