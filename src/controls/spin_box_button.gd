@tool
extends HBoxContainer
class_name SpinBoxButton


@export var spin_box: SpinBox = null
@export var button: Button = null

@export var text: String = "":
	set(value):
		text = value
		button.text = text
@export var suffix: String = "":
	set(value):
		suffix = value
		spin_box.suffix = suffix
@export var step: float = 0:
	set(v):
		step = v
		spin_box.step = v
@export var value: float = 0:
	set(v):
		spin_box.value = v
		value = spin_box.value
