extends VScrollBar


@export_group("Ref")
## 轨道适应滚动容器引用。
@export var track_adaptive_scroll_container: ScrollContainer = null
## 左滚动容器引用。
@export var left_scroll_container: ScrollContainer = null
## 右滚动容器引用。
@export var right_scroll_container: ScrollContainer = null

## 轨道适应滚动容器子项引用。
@onready var track_adaptive_scroll_container_child: Control = track_adaptive_scroll_container.get_child(0)


func _ready() -> void:
	value_changed.connect(_on_value_changed)
	track_adaptive_scroll_container.resized.connect(_update_page)
	track_adaptive_scroll_container_child.resized.connect(_on_track_adaptive_scroll_container_child_resized)
		

func _on_value_changed(v: int)  -> void:
	track_adaptive_scroll_container.scroll_vertical = v
	left_scroll_container.scroll_vertical = v
	right_scroll_container.scroll_vertical = v


## 更新滚动条页面。
func _update_page() -> void:
	page = track_adaptive_scroll_container.size.y

	if page == max_value:
		visible = false
	else:
		visible = true


func _on_track_adaptive_scroll_container_child_resized() -> void:
	max_value = track_adaptive_scroll_container_child.size.y
	_update_page()
