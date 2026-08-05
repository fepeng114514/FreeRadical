@tool
extends Camera2D
class_name Camera
## 相机类，用于控制游戏中的相机。


## 缩放因子。
@export var zoom_factor: float = 1.1
## 缩放时长。
@export var zoom_duration: float = 0.2
## 最小缩放。
@export var zoom_min: float = 0.0
## 最大缩放。
@export var zoom_max: float = 1.5

## 是否正在拖拽。
var _dragging: bool = false
## 拖拽位置。
var _drag_start_position := Vector2.ZERO


func _ready() -> void:
	if Engine.is_editor_hint():
		pass
	else:
		get_viewport().size_changed.connect(_on_resized_window)
		
		_reset_zoom()
	

func _unhandled_input(event: InputEvent) -> void:
	# 滚动事件
	if event.is_action("camera_zoom_in"):
		_smooth_zoom(false)
		
	elif event.is_action("camera_zoom_out"):
		_smooth_zoom(true)
	
	# 左键点击事件开始拖动
	elif event.is_action_pressed("camera_drag"):
		_dragging = true
		_drag_start_position = event.position
	# 左键点击事件松开结束拖动
	elif event.is_action_released("camera_drag"):
		_dragging = false
	
	# 拖动时鼠标移动移动相机
	if not _dragging:
		return
		
	_move(event.position)


## 平滑缩放。
func _smooth_zoom(reversed: bool = false) -> void:
	var target_zoom: Vector2
	
	if reversed:
		target_zoom = zoom / zoom_factor
	else:
		target_zoom = zoom * zoom_factor
	
	# 限制缩放范围
	target_zoom = target_zoom.clampf(zoom_min, zoom_max)
	
	var tween: Tween = create_tween()
	tween.set_parallel(false)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "zoom", target_zoom, zoom_duration)


## 移动相机。
func _move(target_pos: Vector2) -> void:
	# 计算鼠标移动距离
	var drag_offset: Vector2 = _drag_start_position - target_pos
	# 移动相机（注意：要除以缩放倍数，否则缩放后拖动速度不对）
	position += drag_offset / zoom
	_drag_start_position = target_pos


## 重置缩放。
func _reset_zoom() -> void:
	var window_size_factor: Vector2 = (
		GlobalMgr.window_size / GlobalMgr.max_window_size
	)
	zoom_min = window_size_factor.x
	zoom = Vector2(zoom_min, zoom_min)


func _on_resized_window() -> void:
	_reset_zoom()
