extends TextureProgressBar



@export var tween_duration: float = 0.1

var value_tween: Tween = null


func _ready() -> void:
	LoaderMgr.loading_progress.connect(_on_loading_progress)

	value = 0.0


func _on_loading_progress(progress: float):
	if value_tween:
		value_tween.kill()

	value_tween = create_tween()
	value_tween.tween_property(self, "value", progress, tween_duration)
	
