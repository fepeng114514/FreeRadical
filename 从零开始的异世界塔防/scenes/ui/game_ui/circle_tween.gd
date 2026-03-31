extends Sprite2D
class_name CircleTween


## 补间缩放时长
@export var scale_time: float = 0.25


func tween_set_scale(target_scale: Vector2):
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "scale", target_scale, scale_time)
	

func remove() -> void:
	tween_set_scale(Vector2.ZERO)
	await get_tree().create_timer(scale_time).timeout
	queue_free()
