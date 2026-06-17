extends Button


## 文件对话框引用。
@export var file_dialog: FileDialog = null


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	file_dialog.visible = true
