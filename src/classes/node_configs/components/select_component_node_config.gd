@tool
extends NodeConfig
class_name SelectComponentNodeConfig
## 选择组件节点配置资源。


## 选择矩形大小。
@export var select_rect := Rect2(-16, -16, 32, 32):
	set(v):
		select_rect = v
		emit_changed()
## 是否可以选择。
@export var can_select: bool = true:
	set(v):
		can_select = v
		emit_changed()

## 信息栏类型。
@export var info_bar_type: SelectComponent.InfoBarType = SelectComponent.InfoBarType.NONE
## 选择菜单类型。
@export var select_menu_type: SelectComponent.SelectMenuType = SelectComponent.SelectMenuType.NONE
## 选择菜单偏移。
@export var select_menu_offset := Vector2.ZERO:
	set(v):
		select_menu_offset = v
		emit_changed()
