extends VBoxContainer


@export var track_editor: TrackEditor = null
@export var spacer: Control = null


func _ready() -> void:
	track_editor.ruler.resized.connect(_on_ruler_resized)
		
		
func _on_ruler_resized() -> void:
	spacer.custom_minimum_size.y = track_editor.ruler.size.y
		
