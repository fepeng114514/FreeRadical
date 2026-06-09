@tool
extends Resource
class_name AnimationGroup
## 动画组资源。
##
## AnimationGroup 存储动画名称，用于根据实体看向的方向获取动画名称。[br][br]
## 根据填写的属性会动态生成三种动画组：[br]
## 1. 双方向动画组：填写 [member left]、[member right] 或 [member up]、[member down]，每个 180 度表示一个动画名称。[br]
## 2. 四方向动画组：填写所有方向的动画名称 [member left]、[member right]、[member up]、[member down]，每个 90 度表示一个动画名称。[br]


## 要播放的精灵/精灵组索引。
@export var play_idx: int = 0
## 播放次数。
@export var times: int = 1
## 左方向的动画名。
@export var left: StringName = &""
## 右方向的动画名。
@export var right: StringName = &""
## 右方向的动画是否以镜像方式替换左方向的动画。
@export var right_replace_left: bool = false:
	set(v): 
		right_replace_left = v
		notify_property_list_changed()
## 上方向的动画名。
@export var up: StringName = &""
## 下方向的动画名。
@export var down: StringName = &""
## 上下方向是否启用镜像，仅用于双方向动画组。
@export var vertical_mirror: bool = false
## 任意方向的动画名。
@export var any: StringName = &""


func _validate_property(property: Dictionary):
	match property.name:
		"left":
			if right_replace_left:
				property.usage = PROPERTY_USAGE_NONE


## 根据实体与目标点的角度返回对应的动画名称。
func get_animation_name_for_point(center: Vector2, point: Vector2) -> AnimationData:
	var anim_data := AnimationData.new()
	
	if any:
		anim_data.anim_name = any
		return anim_data

	var has_horizontal: bool = left or right
	var has_vertical: bool = up or down
	var direction: C.Direction = C.Direction.NONE
	var anim_name: StringName = ""
	var flip_h: bool = false

	if has_horizontal and has_vertical:
		var angle: float = center.angle_to_point(
			point
		)
		direction = U.get_cardinal_direction(angle)
		match direction:
			C.Direction.UP:
				anim_name = up
			C.Direction.DOWN:
				anim_name = down
			C.Direction.LEFT:
				if right_replace_left:
					anim_name = right
					flip_h = true
				else:
					anim_name = left
			C.Direction.RIGHT:
				anim_name = right
	elif has_horizontal or has_vertical:
		direction = U.get_quadrant_direction(center, point)
		if has_horizontal:
			match direction:
				C.Direction.LEFT_UP, C.Direction.LEFT_DOWN:
					if right_replace_left:
						anim_name = right
						flip_h = true
					else:
						anim_name = left
				C.Direction.RIGHT_UP, C.Direction.RIGHT_DOWN:
					anim_name = right
		elif has_vertical:
			if vertical_mirror and direction & C.Direction.LEFT:
				flip_h = true

			match direction:
				C.Direction.LEFT_UP, C.Direction.RIGHT_UP:
					anim_name = up
				C.Direction.LEFT_DOWN, C.Direction.RIGHT_DOWN:
					anim_name = down
		
	anim_data.anim_name = anim_name
	anim_data.direction = direction
	anim_data.flip_h = flip_h
	
	return anim_data


## 序列化为字典。
func to_dict() -> Dictionary[String, StringName]:
	return {
		"left": left,
		"right": right,
		"up": up,
		"down": down,
		"any": any,
	}
