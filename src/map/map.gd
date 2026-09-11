extends Node2D


@export var music: AudioGroup = null


func _ready() -> void:
	AudioManager.play_music(music)
