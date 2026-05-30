extends HScrollBar


@export var main_scroll_container: ScrollContainer = null

@onready var main_scroll_container_child: Control = main_scroll_container.get_child(0)


func _ready() -> void:
	value_changed.connect(_on_value_changed)
	main_scroll_container.resized.connect(_update_page)
	main_scroll_container_child.resized.connect(_on_main_scroll_container_child_resized)
		
		
func _on_value_changed(v: int)  -> void:
	main_scroll_container.scroll_horizontal = v


func _update_page() -> void:
	page = main_scroll_container.size.x

	if page == max_value:
		visible = false
	else:
		visible = true


func _on_main_scroll_container_child_resized() -> void:
	max_value = main_scroll_container_child.size.x
	_update_page()
