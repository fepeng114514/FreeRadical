extends HBoxContainer


@export_group("NodeRef")
## 生命图标控件
@export var life_icon: TextureRect = null
## 生命值控件
@export var life_value: Label = null
## 金币图标控件
@export var gold_icon: TextureRect = null
## 金币值控件
@export var gold_value: Label = null


func _ready() -> void:
	S.set_gold.connect(_on_set_gold)
	S.set_life.connect(_on_set_life)


## 设置金币时调用的信号处理函数
func _on_set_gold(new_value: float) -> void:
	pass
	
	
## 设置生命时调用的信号处理函数
func _on_set_life(new_value: float) -> void:
	pass
