@tool
extends HBoxContainer
class_name SpinBoxLabel


@export_category("Label")
@export var text: String = "":
	set(v): 
		text = v
		if label:
			label.text = v
		
@export_category("SpinBox")
@export var prefix: String = "":
	set(v): 
		prefix = v
		if spin_box:
			spin_box.prefix = v
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
@export var label: Label = null


func _ready():
	label.text = text
	spin_box.prefix = prefix
	spin_box.suffix = suffix
	spin_box.step = step
	spin_box.value = value
