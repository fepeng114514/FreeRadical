extends HBoxContainer
class_name TrackEditorMouseToolBar


## 工具按钮被切换时发出。
signal tool_button_toggled(opened_tools: int)


## 已打开的工具标志。
var opened_tools: int = 0


## 设置已打开的工具。
func set_opened_tools(tool_button: TrackEditorMouseToolButton, toggled_on: bool) -> void:
	if toggled_on:
		opened_tools |= tool_button.tool_flag
		
		if tool_button.is_single_selection:
			for child: Control in get_children():
				if not child is TrackEditorMouseToolButton:
					continue
				
				if child == tool_button:
					continue

				if child.is_single_selection:
					child.button_pressed = false
					opened_tools &= ~child.tool_flag
	else:
		opened_tools &= ~tool_button.tool_flag

	tool_button_toggled.emit(opened_tools)
