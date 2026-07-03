@tool
extends Control
class_name WaveFlag
## 波次标识
##
## 用于显示波次到来时间与释放波次


## 绑定的 [Pathway] 路径节点。
@export var bound_pathway_node: Pathway = null:
	set(v):
		bound_pathway_node = v
		update_configuration_warnings()

## 箭头旋转角度
@export_range(-180, 180, 0.1, "radians_as_degrees") var arrow_rotation: float = 0.0:
	set(v):
		arrow_rotation = v
		
		if arrow:
			arrow.rotation = v
		if arrow_glow:
			arrow_glow.rotation = v
		
		update_configuration_warnings()
			
@export_group("Tween")
## 循环缩放时长
@export var tween_loop_scale_duration: float = 0.5
## 循环补间缩放目标值
@export var tween_loop_target_scale := Vector2(1.15, 1.15)
## 计数结束补间缩放时长
@export var tween_end_duration: float = 0.3
## 计数结束补间缩放目标值
@export var tween_end_target_scale := Vector2(1.5, 1.5)
## 计数结束补间调色目标值
@export var tween_end_modulate_scale := Color.TRANSPARENT

@export_group("Ref")
@export var arrow: TextureRect = null
@export var decoration: TextureRect = null
@export var progress_bar: TextureProgressBar = null
@export var arrow_glow: TextureRect = null
@export var border_glow: TextureRect = null
@export var texture_button: TextureButton = null

var loop_tween: Tween = null
var value_tween: Tween = null

@onready var glow_list: Array[TextureRect] = [
	border_glow,
	arrow_glow,
]

func _ready() -> void:
	if Engine.is_editor_hint():
		pass
	else:
		visible = false

		for glow: TextureRect in glow_list:
			glow.visible = false
		
		texture_button.pressed.connect(_on_pressed)
		mouse_entered.connect(_on_mouse_entered)
		mouse_exited.connect(_on_mouse_exited)
		WaveMgr.release_wave.connect(_on_release_wave)
		
		arrow.rotation = arrow_rotation
		arrow_glow.rotation = arrow_rotation
		
		_create_loop_tween()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []

	if not bound_pathway_node:
		warnings.append("请在 bound_pathway_node 中绑定一个 Pathway 路径节点。")

	if not arrow_rotation:
		warnings.append("arrow_rotation 箭头旋转角度为 0，是否忘记设置？。")
		
	return warnings	
	
	
func _on_mouse_entered() -> void:
	for glow: TextureRect in glow_list:
		glow.visible = true
	
	
func _on_mouse_exited() -> void:
	for glow: TextureRect in glow_list:
		glow.visible = false
	

func _create_loop_tween() -> void:
	loop_tween = create_tween()
	loop_tween.set_loops()
	
	loop_tween.set_ease(Tween.EASE_IN_OUT)
	loop_tween.set_trans(Tween.TRANS_SINE)
	loop_tween.tween_property(self, "scale", tween_loop_target_scale, tween_loop_scale_duration)
	loop_tween.tween_property(self, "scale", Vector2.ONE, tween_loop_scale_duration)
	

func _show(time: float) -> void:
	visible = true
	progress_bar.value = progress_bar.min_value
	
	_create_loop_tween()
	
	value_tween = create_tween()
	value_tween.tween_property(progress_bar, "value", progress_bar.max_value, time)

	await value_tween.finished
	
	_hide()
	
	
func _hide() -> void:
	var end_tween: Tween = create_tween()
	end_tween.set_parallel(true)
	end_tween.tween_property(self, "scale", tween_end_target_scale, tween_end_duration)
	end_tween.tween_property(self, "modulate", tween_end_modulate_scale, tween_end_duration)
	
	await end_tween.finished
	
	visible = false
	modulate = Color.WHITE


func _on_release_wave(_wave_idx: int) -> void:
	if loop_tween:
		loop_tween.kill()
	if value_tween:
		value_tween.kill()
		
	_hide()


func _on_pressed() -> void:
	WaveMgr.is_release_wave = true
	if WaveMgr.is_wait_first_release_wave:
		WaveMgr.first_release_wave.emit()
		WaveMgr.is_first_release_wave = false
