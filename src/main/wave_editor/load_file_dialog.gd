extends FileDialog


## 波次编辑器引用。
@export var wave_editor: WaveEditor = null


func _ready() -> void:
	file_selected.connect(_on_file_selected)


func _on_file_selected(path: String) -> void:
	wave_editor.load_wave_group(path)
