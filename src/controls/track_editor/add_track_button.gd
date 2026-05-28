extends TextureButton


@export var track_editor: TrackEditor = null


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	track_editor.create_track()
