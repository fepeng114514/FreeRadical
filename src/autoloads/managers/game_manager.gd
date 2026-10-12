@tool
extends Node
## 游戏管理器。
## 
## [GameManager] 负责管理游戏中的数据与相关操作。


@warning_ignore_start("unused_signal")
## 金币发生更改时发出。
signal cash_changed(new_cash: float)
## 生命发生更改时发出。
signal life_changed(new_life: int)
## 暂停游戏时发出。
signal paused
## 取消暂停游戏时发出。
signal resumed
@warning_ignore_restore("unused_signal")


var is_paused: bool = false
## 金币。
var cash: float = 0.0:
	set(v): 
		cash_changed.emit(v)
		cash = v
## 生命。
var life: int = 20:
	set(v): 
		life_changed.emit(v)
		life = v
## 默认塔位场景路径。
var default_tower_holder: String = ""
## 是否战斗中。
var is_battling: bool = false


func cleanup() -> void:
	is_paused = false
	cash = 0.0
	life = 20
	is_battling = false
	

## 暂停游戏。
func pause_game() -> void:
	Log.info("暂停游戏")
	is_paused = true
	get_tree().paused = true
	paused.emit()

	
## 取消暂停游戏。
func resume_game() -> void:
	Log.info("取消暂停游戏")
	is_paused = false
	get_tree().paused = false
	resumed.emit()
	
	
## 重新开始游戏。
func replay_game() -> void:
	Log.info("重新开始游戏")
	is_paused = false
	
	get_tree().reload_current_scene()
