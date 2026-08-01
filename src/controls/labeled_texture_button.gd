@tool
extends MarginContainer
class_name LabeledTextureButton


## 当按钮被切换或按下时发出
signal pressed


@export_category("Label")
## 标签文本。
@export var text: String = "":
	set(v): 
		text = v
		if label:
			label.text = v

@export_group("Ref")
## 选项按钮引用。
@export var texture_button: TextureButton = null
## 标签引用。
@export var label: Label = null


func _ready():
	label.text = text
	
	texture_button.pressed.connect(_on_texture_button_pressed)
	
	
func _on_texture_button_pressed() -> void:
	pressed.emit()
