@tool
extends ScrollContainer
class_name HScrollContainer
## 水平滚动条容器。


func _ready() -> void:
	vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
