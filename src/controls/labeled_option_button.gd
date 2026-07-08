@tool
extends HBoxContainer
class_name LabeledOptionButton


@export_category("Label")
## 标签文本。
@export var text: String = "":
	set(v): 
		text = v
		if label:
			label.text = v

@export_group("Ref")
## 选项按钮引用。
@export var option_button: OptionButton = null
## 标签引用。
@export var label: Label = null


func _ready():
	label.text = text
