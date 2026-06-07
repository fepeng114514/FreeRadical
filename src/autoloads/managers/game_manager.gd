extends Node
## 游戏管理器。
##
## 负责管理游戏中的数据与相关操作。


@warning_ignore_start("unused_signal")
## 金币变化信号。
signal cash_changed(new_cash: float)
## 生命变化信号。
signal life_changed(new_life: int)
@warning_ignore_restore("unused_signal")


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
## 默认塔位样式。
var defaul_tower_holder: StringName = &"tower_holder_grass"
