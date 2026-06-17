extends Control


@export var level_idx: int = 0

@export_group("Ref")
@export var area: Area2D = null


func _ready() -> void:
	area.input_event.connect(_on_input_event)


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	# 检查输入是否为鼠标左键按下事件
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Area2D 被点击了！")
