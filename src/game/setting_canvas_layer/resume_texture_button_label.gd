@tool
extends LabeledTextureButton


@export var setting_canvas_layer: SettingCanvasLayer = null


func _ready() -> void:
	super()
	
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	setting_canvas_layer.hide_setting()
	GameMgr.resume_game()
