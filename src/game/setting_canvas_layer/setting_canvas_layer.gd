extends SettingCanvasLayer


func _ready() -> void:
	super()
	
	GameManager.paused.connect(_on_paused)


func _on_paused() -> void:
	show_setting()
