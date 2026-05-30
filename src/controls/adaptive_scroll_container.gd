extends ScrollContainer
class_name AdaptiveScrollContainer


var max_custom_minimum_size := Vector2.ZERO


func _ready() -> void:
	max_custom_minimum_size = custom_minimum_size
	
	if get_child_count() == 0:
		return

	var child: Control = get_child(0)
	if not child:
		return
	
	child.resized.connect(
		func() -> void:
			custom_minimum_size = child.size.clamp(Vector2.ZERO, max_custom_minimum_size)
	)
