@tool
extends EditorPlugin

var inspector_plugin: EditorInspectorPlugin

func _enter_tree() -> void:
	# 实例化你的检查器插件并注册
	inspector_plugin = preload("res://addons/mask_check/mask_check_inspector_plugin.gd").new()
	add_inspector_plugin(inspector_plugin)

func _exit_tree() -> void:
	# 清理时移除插件
	remove_inspector_plugin(inspector_plugin)
