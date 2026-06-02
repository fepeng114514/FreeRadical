extends Button


@export var right_track_tool_bar_item: TrackEditorRightTrackToolBarItem = null

@onready var track_editor: TrackEditor = right_track_tool_bar_item.track_editor


func _ready() -> void:
	pressed.connect(_on_pressed)
	
	
func _on_pressed() -> void:
	var track_idx: int = get_index()
	
	var track: TrackEditorTrack = track_editor.get_track(track_idx)
	track.queue_free()
	right_track_tool_bar_item.queue_free()
	var left_track_tool_bar: VBoxContainer = track_editor.left_track_tool_bar
	left_track_tool_bar.get_child(track_idx).free()
	
	for left_item: TrackEditorLeftTrackToolBarItem in left_track_tool_bar.get_children():
		left_item.update_number()
