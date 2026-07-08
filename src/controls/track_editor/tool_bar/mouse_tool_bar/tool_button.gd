extends Button
class_name TrackEditorMouseToolButton


## 工具标志枚举。
enum ToolFlag {
	## 工具标识：无。
	NONE = 0,
	## 工具标识：选择。
	SELECT = 1,
	## 工具标识：编辑。
	EDIT = 1 << 1,
	## 工具标识：擦除。
	ERASE = 1 << 2,
	## 工具标识：移动。
	MOVE = 1 << 3,
	## 工具标识：轨道吸附。
	SNAP = 1 << 4,
}


## 工具标志。
@export var tool_flag: ToolFlag = ToolFlag.NONE
## 是否为单选工具，如果当前工具被选中，其他单选工具会被取消选中。
@export var is_single_selection: bool = false


## 鼠标工具栏引用。
@onready var mouse_tool_bar: TrackEditorMouseToolBar = get_parent()


func _ready() -> void:
	if button_pressed:
		mouse_tool_bar.opened_tools |= tool_flag


func _toggled(toggled_on: bool) -> void:
	mouse_tool_bar.set_opened_tools(self, toggled_on)
