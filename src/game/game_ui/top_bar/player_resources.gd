extends TextureRect


@export_group("NodeRef")
## 生命值控件
@export var life_value: Label = null
## 金币值控件
@export var cash_value: Label = null
## 波次值控件
@export var wave_value: Label = null


func _ready() -> void:
	GameMgr.cash_changed.connect(_on_cash_changed)
	GameMgr.life_changed.connect(_on_life_changed)
	WaveMgr.release_wave.connect(_on_release_wave)
	
	wave_value.text = "0/%d" % WaveMgr.get_wave_count()


func _on_cash_changed(new_cash: float) -> void:
	cash_value.text = "%d" % new_cash
	
	
func _on_life_changed(new_life: int) -> void:
	life_value.text = "%d" % new_life


func _on_release_wave(wave_idx: int) -> void:
	wave_value.text = "%d/%d" % [wave_idx + 1, WaveMgr.get_wave_count()]
