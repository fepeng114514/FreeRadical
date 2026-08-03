@tool
extends ScrollContainer
class_name AutoScrollContainer
## 自适应滚动容器。
##
## AutoScrollContainer 会根据子容器大小来自动调节 [member custom_minimum_size]。
## 用于解决滚动容器大小不适应子容器的问题。


## 第一个子项引用。
@onready var _first_child: Control = get_child(0) if get_child_count() > 0 else null


func _ready() -> void:
	if not _first_child:
		return
		
	_update_custom_minimum_size()
	
	_first_child.resized.connect(_update_custom_minimum_size)


func _update_custom_minimum_size() -> void:
	custom_minimum_size = _first_child.size
