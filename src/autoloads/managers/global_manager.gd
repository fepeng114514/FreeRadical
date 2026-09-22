@tool
extends Node
## 全局管理器。
## 
## 负责管理全局状态与相关操作。


## 最大窗口大小。
var max_window_size := Vector2(2560, 1440)
## 当前窗口大小。
var window_size := Vector2.ZERO
## 世界大小。
var world_size := Vector2(2560, 1440)
## 所有全局类名到类数据的映射，见 [method ProjectSettings.get_global_class_list]。
var global_classes: Dictionary[String, Dictionary] = {}


func _ready() -> void:
	get_viewport().size_changed.connect(_on_size_changed)
	window_size = get_viewport().get_visible_rect().size
	
	for cls: Dictionary in ProjectSettings.get_global_class_list():
		global_classes[cls.class] = cls


func _on_size_changed() -> void:
	var new_size: Vector2 = get_viewport().get_visible_rect().size
	
	Log.debug("重设窗口大小: %s" % new_size)
	window_size = new_size
