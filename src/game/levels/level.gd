extends Node
class_name Level
## 关卡节点。


## 初始金币。
@export var cash: int = 200
## 初始生命。
@export var life: int = 20
## 默认塔位样式。
@export_file("*.tscn") var defaul_tower_holder: String = ""
## 地图大小。
@export var world_size := Vector2(2560, 1440)

@export_group("Music")
## 准备阶段播放的音乐数据。
@export var ready_music: AudioGroup = null
## 战斗阶段播放的音乐数据。
@export var battle_music: AudioGroup = null


func _enter_tree() -> void:
	NodeConfigManager.init()
		
	GlobalManager.world_size = world_size
	GameManager.defaul_tower_holder = defaul_tower_holder
	WaveManager.first_release_wave.connect(_on_first_release_wave)


func _exit_tree() -> void:
	GridManager.clear()
	SelectManager.clear()
	PathwayManager.clear()
	WaveManager.clear()
	NodeConfigManager.clear()

	get_tree().paused = false
	Engine.time_scale = 1.0


func _ready() -> void:
	GameManager.cash = cash
	GameManager.life = life
	
	if ready_music:
		AudioManager.play_music(ready_music)
	

func _on_first_release_wave() -> void:
	AudioManager.play_music(battle_music)
