extends Node2D


@export var music: AudioGroup = null


func _ready() -> void:
	AudioMgr.play_music(music)
