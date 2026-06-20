extends Control
class_name RangeCircle


@export var scale_tween_duration: float = 0.15

var scale_tween: Tween = null
var last_radius: float = 0.0

@onready var range_info: RangeInfo = get_parent()


func _ready() -> void:
	scale = Vector2.ZERO
	visible = false


func _show(radius: float) -> void:
	if last_radius == radius:
		return

	visible = true

	_create_scale_tween(radius)


func _hide() -> void:
	_create_scale_tween(0.0)

	await scale_tween.finished
	range_info.free_child(self)


func _create_scale_tween(target_radius: float) -> void:
	last_radius = target_radius

	var target_scale = target_radius / (size.x / 2) * Vector2.ONE

	if scale_tween:
		scale_tween.kill()
		
	scale_tween = create_tween()
	scale_tween.set_ease(Tween.EASE_OUT)
	scale_tween.set_trans(Tween.TRANS_SINE)
	scale_tween.tween_property(self, "scale", target_scale, scale_tween_duration)
