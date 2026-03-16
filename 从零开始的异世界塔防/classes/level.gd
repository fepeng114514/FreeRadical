extends Node2D
class_name Level

## 准备阶段播放的音乐数据
@export var ready_music: AudioData = null
## 战斗阶段播放的音乐数据
@export var battle_music: AudioData = null

func _ready() -> void:
	if ready_music:
		AudioMgr.play_music(ready_music)
	
