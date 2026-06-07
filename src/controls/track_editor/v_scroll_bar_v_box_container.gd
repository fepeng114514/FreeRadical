extends VBoxContainer


@export_group("Ref")
## 轨道编辑器引用。
@export var track_editor: TrackEditor = null
## 间距引用
@export var spacer: Control = null


func _ready() -> void:
	track_editor.ruler.resized.connect(_on_ruler_resized)
		
		
func _on_ruler_resized() -> void:
	spacer.custom_minimum_size.y = track_editor.ruler.size.y
		
