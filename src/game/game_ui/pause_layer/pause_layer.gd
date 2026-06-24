extends CanvasLayer


func _ready() -> void:
	GameMgr.pause_game.connect(_on_pause_game)
	GameMgr.continue_game.connect(_on_continue_game)

	visible = false


func _on_pause_game() -> void:
	get_tree().paused = true
	visible = true


func _on_continue_game() -> void:
	get_tree().paused = false
	visible = false
