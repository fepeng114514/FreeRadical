@tool
extends EditorPlugin


const ECS_DIR: String = "res://addons/godot_ecs/"
const ECS_AUTOLOADS_DIR: String = "res://addons/godot_ecs/autoloads/"

const MANAGER_PATH_DICT: Dictionary[String, String] = {
	"ECSSettingManager": ECS_AUTOLOADS_DIR + "ecs_setting_manager.gd",
	"ECSEntityManager": ECS_AUTOLOADS_DIR + "ecs_entity_manager.gd",
	"ECSSystemManager": ECS_AUTOLOADS_DIR + "ecs_system_manager.gd",
}

var ecs_dock: ECSDock


func _enter_tree() -> void:
	ecs_dock = preload(ECS_DIR + "ecs_dock/ecs_dock.tscn").instantiate()
	add_dock(ecs_dock)
	
	
func _exit_tree() -> void:
	remove_dock(ecs_dock)
	ecs_dock.queue_free()


func _enable_plugin() -> void:
	for manager_name: String in MANAGER_PATH_DICT:
		add_autoload_singleton(manager_name, MANAGER_PATH_DICT[manager_name])
	

func _disable_plugin() -> void:
	for manager_name: String in MANAGER_PATH_DICT:
		remove_autoload_singleton(manager_name)
		
