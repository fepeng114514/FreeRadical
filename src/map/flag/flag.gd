@tool
extends Node2D


@export_file("*.tscn") var level_scene_path: String = "":
	set(v):
		level_scene_path = v
		update_configuration_warnings()

@export_group("Ref")
@export var animated_sprite: AnimatedSprite2D = null
@export var area: Area2D = null


func _ready() -> void:
	area.input_event.connect(_on_input_event)
	
	animated_sprite.play("unlocked_idle")


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
		
	if not level_scene_path:
		warnings.append("请在 level_scene_path 中设置一个关卡场景路径，否则点击旗帜不会进入关卡。")
		
	return warnings


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			ChangeSceneMgr.enter_scene(level_scene_path)
