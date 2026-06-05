extends Button


@export var right_track_tool_bar_item: TrackEditorRightTrackToolBarItem = null

@onready var track_editor: TrackEditor = right_track_tool_bar_item.track_editor


func _ready() -> void:
	pressed.connect(_on_pressed)
	
	
func _on_pressed() -> void:
	track_editor.remove_track(right_track_tool_bar_item.get_index())
		
	for left_item: TrackEditorLeftTrackToolBarItem in track_editor.left_track_tool_bar.get_children():
		left_item.update_number()
