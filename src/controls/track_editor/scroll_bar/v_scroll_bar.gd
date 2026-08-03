extends VScrollBar


@export var track_auto_scroll_container: AutoScrollContainer = null
@export var left_track_tool_v_scroll_container: VScrollContainer = null
@export var right_track_tool_v_scroll_container: VScrollContainer = null

@onready var _track_auto_scroll_container_child: Control = track_auto_scroll_container.get_child(0)


func _ready() -> void:
	value_changed.connect(_on_value_changed)
	track_auto_scroll_container.resized.connect(_update_page)
	_track_auto_scroll_container_child.resized.connect(_update_max_value)
		
	_update_max_value()
	_update_page()


func _on_value_changed(v: int)  -> void:
	track_auto_scroll_container.scroll_vertical = v
	left_track_tool_v_scroll_container.scroll_vertical = v
	right_track_tool_v_scroll_container.scroll_vertical = v


## 更新滚动条页面。
func _update_page() -> void:
	page = track_auto_scroll_container.size.y

	if page == max_value:
		visible = false
	else:
		visible = true


func _update_max_value() -> void:
	max_value = _track_auto_scroll_container_child.size.y

	_update_page()
