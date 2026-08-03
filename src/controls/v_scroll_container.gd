@tool
extends ScrollContainer
class_name VScrollContainer
## 垂直滚动条容器。


func _ready() -> void:
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
