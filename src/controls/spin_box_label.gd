@tool
extends HBoxContainer
class_name SpinBoxLabel


@export var spin_box: SpinBox = null
@export var label: Label = null

@export var text: String = "":
	set(value):
		text = value
		label.text = text
@export var prefix: String = "":
	set(value):
		prefix = value
		spin_box.prefix = prefix
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
