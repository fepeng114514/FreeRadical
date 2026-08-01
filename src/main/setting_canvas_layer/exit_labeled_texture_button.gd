@tool
extends LabeledTextureButton


func _ready() -> void:
	super()
	
	pressed.connect(_on_pressed)
	

func _on_pressed() -> void:
	get_tree().quit()
