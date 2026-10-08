extends Button


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	DebugMenu.style = wrapi(DebugMenu.style + 1, 0, DebugMenu.Style.MAX) as DebugMenu.Style
	DebugMenu.display_size = DebugMenu.Display_Size.SIZE_24
