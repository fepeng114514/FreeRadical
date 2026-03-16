extends Node2D
class_name Level

## 准备阶段播放的音乐 uid
@export_file("*.ogg") var ready_music_uid: String = ""
## 战斗阶段播放的音乐 uid
@export_file("*.ogg") var battle_music_uid: String = ""

func _ready() -> void:
	AudioMgr.play_music(ready_music_uid)
	
