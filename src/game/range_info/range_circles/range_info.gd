extends Control
class_name RangeInfo


@export var size_tween_duration: float = 0.15

@export_group("Ref")
@export var min_range_circle: RangeCircle = null
@export var max_range_circle: RangeCircle = null

var target_entity: Entity = null
var target_source: Entity = null
var freed_circle_count: int = 0
var is_hidden: bool = false


func _ready() -> void:
	_update()


func _update() -> void:
	pass


func _hide() -> void:
	is_hidden = true

	for circle: RangeCircle in get_children():
		circle._hide()


func free_child(child: RangeCircle) -> void:
	freed_circle_count += 1
	child.queue_free()

	if freed_circle_count >= get_child_count():
		queue_free()
