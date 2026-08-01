extends Node2D
class_name Main


@export var music: AudioGroup = null


func _ready() -> void:
	AudioMgr.play_music(music)
