extends HBoxContainer


@export var track_editor: TrackEditor = null
@export var left_spacer: Control = null
@export var right_spacer: Control = null


func _ready() -> void:
	track_editor.left_track_tool_bar.resized.connect(_on_left_track_tool_bar_resized)
	track_editor.right_track_tool_bar.resized.connect(_on_right_track_tool_bar_resized)


func _on_left_track_tool_bar_resized() -> void:
	left_spacer.custom_minimum_size.x = track_editor.left_track_tool_bar.size.x


func _on_right_track_tool_bar_resized() -> void:
	right_spacer.custom_minimum_size.x = track_editor.right_track_tool_bar.size.x
		
