@tool
extends Component
class_name UIComponent
## UI 组件。
##
## UIComponent 可以使实体在屏幕上显示信息栏、选择菜单等 UI 元素。


## 选择矩形大小。
@export var select_rect := Rect2(-16, -16, 32, 32):
	set(v): 
		select_rect = v
		U.redraw_setter(self)
## 是否可以选择。
@export var can_select: bool = true:
	set(v): 
		can_select = v
		U.redraw_setter(self)

## 信息栏类型。
@export var info_bar_type: C.InfoBarType = C.InfoBarType.NONE
## 选择菜单偏移。
@export var select_menu_offset := Vector2.ZERO:
	set(v): 
		select_menu_offset = v
		U.redraw_setter(self)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED


func _draw() -> void:
	if Engine.is_editor_hint():
		if not can_select:
			return

		draw_rect(
			Rect2(select_menu_offset - Vector2(4, 4), Vector2(8, 8)), 
			Color.GREEN, 
			true
		)
			
		# 绘制半透明填充和边框
		draw_rect(
			Rect2(select_rect.position, select_rect.size), 
			Color(0.2, 0.6, 1.0, 0.25), 
			true
		)
		draw_rect(
			Rect2(select_rect.position, select_rect.size), 
			Color(0.2, 0.6, 1.0, 0.9), 
			false, 
			1
		)
	

## 获取全局位置的矩形。
func get_global_select_rect(origin: Vector2) -> Rect2:
	return Rect2(origin + select_rect.position, select_rect.size)


## 检测是否点击在矩形内。
func is_click_at(origin: Vector2, clicked_global_pos: Vector2) -> bool:
	return (
		can_select 
		and get_global_select_rect(origin).has_point(clicked_global_pos)
	)
