@tool
extends Area2D
class_name UIComponent


## 信息栏类型
@export var info_bar_type: C.InfoBarType = C.InfoBarType.NONE
## 选择菜单偏移
@export var select_menu_offset: Vector2 = Vector2.ZERO:
	set(value):
		select_menu_offset = value
		queue_redraw()
## 选择菜单数据
@export var select_menu_data: SelectMenuData = null


func _draw() -> void:
	if not Engine.is_editor_hint():
		return

	draw_rect(
		Rect2(select_menu_offset - Vector2(4, 4), Vector2(8, 8)), 
		Color.GREEN, 
		true
	)
