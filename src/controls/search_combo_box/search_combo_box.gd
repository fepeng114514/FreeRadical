@tool
extends Control
class_name SearchComboBox


@export_category("Label")
@export var text: String = "":
	set(v): 
		text = v
		if label:
			label.text = v
	

@export_group("Ref")
@export var label: Label = null
@export var text_edit: TextEdit = null
@export var button: Button = null
@export var popup: Popup = null


func _ready():
	label.text = text
