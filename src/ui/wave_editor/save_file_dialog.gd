extends FileDialog


@export var wave_editor: WaveEditor = null


func _ready() -> void:
	file_selected.connect(_on_file_selected)


func _on_file_selected(path: String) -> void:
	wave_editor.save_wave_group(path)
