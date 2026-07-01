extends Node2D


@export var level_idx: int = 0

@export_group("Ref")
@export var animated_sprite: AnimatedSprite2D = null
@export var area: Area2D = null


func _ready() -> void:
	area.input_event.connect(_on_input_event)
	
	animated_sprite.play("unlocked")


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		ChangeSceneMgr.enter_scene(
			"res://game/levels/level_%d.tscn" % level_idx
		)
