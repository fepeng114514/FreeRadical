@tool
extends LabeledTextureButton


## 按钮按下时进入的场景。
@export_file("*.tscn") var enterted_scene_path: String = ""


func _ready() -> void:
	super()
	
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	ChangeSceneMgr.enter_scene(enterted_scene_path)
	
