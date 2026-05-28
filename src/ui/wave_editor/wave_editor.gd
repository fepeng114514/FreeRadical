extends Control


@export_group("Ref")
@export var wave_track_editor: TrackEditor = null
@export var sub_wave_track_editor: TrackEditor = null


func _ready() -> void:
	sub_wave_track_editor.item_select.connect(_on_sub_wave_track_editor_item_select)
	sub_wave_track_editor.item_deselect.connect(_on_sub_wave_track_editor_item_deselect)


func _on_sub_wave_track_editor_item_select(item: TrackEditorTrackItem) -> void:
	pass


func _on_sub_wave_track_editor_item_deselect() -> void:
	pass
	
