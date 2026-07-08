@tool
extends ScrollContainer
class_name AudoScrollContainer
## 自适应滚动容器。
##
## AudoScrollContainer 会根据子容器大小来自动调节 [member custom_minimum_size]。


## 第一个子项引用。
@onready var first_child: Control = get_child(0) if get_child_count() > 0 else null


func _ready() -> void:
	if not first_child:
		return
		
	_on_child_resized()
	
	first_child.resized.connect(_on_child_resized)


func _on_child_resized() -> void:
	custom_minimum_size = first_child.size
