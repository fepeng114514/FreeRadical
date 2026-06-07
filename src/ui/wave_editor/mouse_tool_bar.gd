extends TrackEditorMouseToolBar


## 波次编辑器引用。
@export var wave_editor: WaveEditor = null


func _ready() -> void:
	tool_button_toggled.connect(_on_tool_button_toggled)


func _on_tool_button_toggled(_opened_tools: int) -> void:
	wave_editor.wave_track_editor.mouse_tool_bar.opened_tools = opened_tools
	wave_editor.sub_wave_track_editor.mouse_tool_bar.opened_tools = opened_tools
	wave_editor.spawn_track_editor.mouse_tool_bar.opened_tools = opened_tools
