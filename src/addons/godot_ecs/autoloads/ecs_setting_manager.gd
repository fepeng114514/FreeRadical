@tool
extends Node


const SETTING_PATH: String = "res://.godot_ecs/ecs_setting.tres"


func _ready() -> void:
	if not ResourceLoader.exists(SETTING_PATH):
		var new_setting := ECSSetting.new()
		ResourceSaver.save(new_setting, SETTING_PATH)


func get_setting() -> ECSSetting:
	return load(SETTING_PATH)
