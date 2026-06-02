extends ScrollContainer
class_name AdaptiveScrollContainer


@onready var max_custom_minimum_size: Vector2 = custom_minimum_size
@onready var first_child: Control = get_child(0) if get_child_count() > 0 else null


func _ready() -> void:
	max_custom_minimum_size = custom_minimum_size
	
	if not first_child:
		return
	
	first_child.resized.connect(_on_child_resized)


func _on_child_resized() -> void:
	custom_minimum_size = first_child.size.clamp(Vector2.ZERO, max_custom_minimum_size)
