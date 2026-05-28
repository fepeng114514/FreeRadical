@tool
extends HBoxContainer
class_name OptionButtonLabel


@export var option_button: OptionButton = null
@export var label: Label = null

@export var text: String = "":
	set(value):
		text = value
		label.text = text
