extends HBoxContainer


@export_group("NodeRef")
## 生命值控件
@export var life_value: Label = null
## 金币值控件
@export var cash_value: Label = null
## 波次值控件
@export var wave_value: Label = null


func _ready() -> void:
	GameMgr.set_cash.connect(_on_set_cash)
	GameMgr.set_life.connect(_on_set_life)
	WaveMgr.release_wave.connect(_on_release_wave)

	wave_value.text = "0/%d" % WaveMgr.wave_group.wave_list.size()


## 设置金币时调用的信号处理函数
func _on_set_cash(new_value: float) -> void:
	cash_value.text = "%d" % new_value
	
	
## 设置生命时调用的信号处理函数
func _on_set_life(new_value: float) -> void:
	life_value.text = "%d" % new_value


func _on_release_wave(wave_idx: int) -> void:
	wave_value.text = "%d/%d" % [wave_idx + 1, WaveMgr.wave_group.wave_list.size()]
