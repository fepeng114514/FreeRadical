@tool
extends HBoxContainer
class_name OptionButtonLabel


@export_category("Label")
@export var text: String = "":
	set(v): 
		text = v
		if label:
			label.text = v

@export_group("Ref")
@export var option_button: OptionButton = null
@export var label: Label = null


func _ready():
	label.text = text
