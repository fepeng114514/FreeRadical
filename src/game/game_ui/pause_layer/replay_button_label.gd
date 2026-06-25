@tool
extends TextureButtonLabel


func _ready() -> void:
	texture_button.pressed.connect(_on_pressed)


func _on_pressed() -> void:
	LevelMgr.enter_level(LevelMgr.current_level_idx)
	
