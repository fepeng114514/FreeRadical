@tool
extends TextureButton
class_name WaveFlag
## 波次标识
##
## 用于显示波次到来时间与释放波次


## 箭头旋转角度
@export_range(-180, 180, 0.1, "radians_as_degrees") var arrow_rotation: float = 0:
	set(value):
		arrow_rotation = value
		
		if not Engine.is_editor_hint():
			return
		
		if arrow:
			arrow.rotation = value

@export_group("Ref")
## 箭头引用
@export var arrow: TextureRect = null
## 装饰引用
@export var decoration: TextureRect = null
## 进度条引用
@export var progress_bar: TextureProgressBar = null
	
@export_group("Tween")
## 缩放时长
@export var scale_duration: float = 0.6
## 补间缩放目标
@export var target_scale: Vector2 = Vector2(1.3, 1.3)

var value_tween: Tween = null

func _ready() -> void:
	if Engine.is_editor_hint():
		return
		#
	#var bit_map := BitMap.new()
	#var texture: AtlasTexture = 
	
	S.start_wave_timer.connect(_start_timer)
	
	arrow.rotation = arrow_rotation
	
	# 创建独立的缩放补间
	var scale_tween: Tween = create_tween()
	scale_tween.set_loops()  # 无限循环
	
	scale_tween.set_ease(Tween.EASE_IN_OUT)
	scale_tween.set_trans(Tween.TRANS_SINE)
	scale_tween.tween_property(self, "scale", target_scale, scale_duration)
	scale_tween.tween_property(self, "scale", Vector2(1.0, 1.0), scale_duration)
	

func _start_timer(wave: Wave) -> void:
	visible = true
	progress_bar.value = progress_bar.min_value
	
	if value_tween:
		value_tween.kill()
		
	value_tween = create_tween()
	value_tween.tween_property(progress_bar, "value", progress_bar.max_value, wave.interval)
	value_tween.tween_callback(func() -> void:
		visible = false
	)
	
