@tool
extends Node


const SETTING_PATH: String = "res://addons/godot_ecs/setting/ecs_setting.tres"


var _setting: ECSSetting = null


func _ready() -> void:
	_setting = load(SETTING_PATH)


func get_setting() -> ECSSetting:
	return _setting
