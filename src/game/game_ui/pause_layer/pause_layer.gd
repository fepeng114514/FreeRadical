extends CanvasLayer


@export var animation_player: AnimationPlayer = null


func _ready() -> void:
	GameMgr.pause_game.connect(_on_pause_game)
	GameMgr.continue_game.connect(_on_continue_game)

	visible = false


func _on_pause_game() -> void:
	get_tree().paused = true
	visible = true
	
	animation_player.play("show")


func _on_continue_game() -> void:
	get_tree().paused = false
	
	animation_player.play("hide")
	
	await animation_player.animation_finished
	visible = false
