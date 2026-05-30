@tool
extends HBoxContainer
class_name SpinBoxButton


@export_category("Button")
@export var text: String = "":
	set(v): 
		text = v
		if button:
			button.text = v

@export_category("SpinBox")
@export var suffix: String = "":
	set(v): 
		suffix = v
		if spin_box:
			spin_box.suffix = v
@export var step: float = 0:
	set(v): 
		step = v
		if spin_box:
			spin_box.step = v
@export var value: float = 0:
	set(v): 
		value = v
		if spin_box:
			spin_box.value = v

@export_group("Ref")
@export var spin_box: SpinBox = null
@export var button: Button = null


func _ready():
	button.text = text
	spin_box.suffix = suffix
	spin_box.step = step
	spin_box.value = value
