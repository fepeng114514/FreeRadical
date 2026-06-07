extends Node
## 全局管理器。
## 
## 负责管理全局状态与相关操作。


## 是否为发布版本。
var is_release: bool = OS.has_feature("release")
## 是否为调试版本。
var is_debug: bool = OS.has_feature("debug")
## 最大窗口大小。
var max_window_size := Vector2(2560, 1440)
## 当前窗口大小。
var window_size := Vector2.ZERO
## 世界大小。
var world_size := Vector2(2560, 1440)


func _ready() -> void:
	get_viewport().size_changed.connect(_on_size_changed)
	window_size = get_viewport().get_visible_rect().size


func _on_size_changed() -> void:
	var new_size: Vector2 = get_viewport().get_visible_rect().size
	
	Log.debug("重设窗口大小: %s" % new_size)
	window_size = new_size
