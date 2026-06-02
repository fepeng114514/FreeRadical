extends Button
class_name TrackEditorMouseToolButton


enum ToolFlag {
	NONE = 0,
	SELECT = 1,
	EDIT = 1 << 1,
	ERASE = 1 << 2,
	MOVE = 1 << 3,
	SNAP = 1 << 4,
}


@export var tool_flag: ToolFlag = ToolFlag.NONE
@export var is_single_selection: bool = false



@onready var mouse_tool_bar: TrackEditorMouseToolBar = get_parent()


func _ready() -> void:
	if button_pressed:
		mouse_tool_bar.opened_tools |= tool_flag


func _toggled(toggled_on: bool) -> void:
	mouse_tool_bar.set_opened_tools(self, toggled_on)
