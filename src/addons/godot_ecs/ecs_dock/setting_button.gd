@tool
extends Button


func _ready() -> void:
	pressed.connect(_on_pressed)
	
	
func _on_pressed() -> void:
	EditorInterface.edit_resource(ECSSettingManager.get_setting())
