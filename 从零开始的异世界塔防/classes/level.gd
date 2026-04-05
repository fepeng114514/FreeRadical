extends Node2D
class_name Level
## 关卡节点


## 初始金币
@export var cash: int = 200
## 初始生命
@export var life: int = 20
## 默认塔位样式
@export var defaul_tower_holder_style: C.TowerHolderStyle = C.TowerHolderStyle.GRASS

@export_group("Music")
## 准备阶段播放的音乐数据
@export var ready_music: AudioData = null
## 战斗阶段播放的音乐数据
@export var battle_music: AudioData = null


func _ready() -> void:
	GameMgr.cash = cash
	GameMgr.life = life
	
	if ready_music:
		AudioMgr.play_music(ready_music)
	
