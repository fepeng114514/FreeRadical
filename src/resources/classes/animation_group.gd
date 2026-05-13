@tool
extends Resource
class_name AnimationGroup
## 动画数据资源


## 要播放的精灵/精灵组索引
@export var play_idx: int = 0
## 播放次数
@export var times: int = 1
## 左方向的动画名
@export var left: StringName = &""
## 左方向的动画是否作为右方向的镜像
@export var mirror_horizontal: bool = false:
	set(value):
		mirror_horizontal = value
		notify_property_list_changed()
## 右方向的动画名
@export var right: StringName = &""
## 上方向的动画名
@export var up: StringName = &""
## 上方向的动画是否作为下方向的镜像
@export var mirror_vertical: bool = false:
	set(value):
		mirror_vertical = value
		notify_property_list_changed()
## 下方向的动画名
@export var down: StringName = &""
## 任意方向的动画名
@export var any: StringName = &""


func _validate_property(property: Dictionary):
	match property.name:
		"left":
			if mirror_horizontal:
				property.usage = PROPERTY_USAGE_NONE
		"up":
			if mirror_vertical:
				property.usage = PROPERTY_USAGE_NONE

## 根据实体与目标点的角度返回对应的动画名称
func get_animation_name_for_point(center: Vector2, point: Vector2) -> AnimationData:
	var anim_data := AnimationData.new()
	
	if any:
		anim_data.anim_name = any
	else:
		var angle: float = center.angle_to_point(
			point
		)
		var has_horizontal: bool = left or right
		var has_vertical: bool = up or down
		anim_data.direction = U.get_direction_by_angle(angle, has_horizontal, has_vertical)
			
		match anim_data.direction:
			C.Direction.UP:
				if mirror_vertical:
					anim_data.anim_name = down
					anim_data.flip_h = true
				else:
					anim_data.anim_name = up
			C.Direction.DOWN:
				anim_data.anim_name = down
			C.Direction.LEFT:
				if mirror_horizontal:
					anim_data.anim_name = right
					anim_data.flip_h = true
				else:
					anim_data.anim_name = left
			C.Direction.RIGHT:
				anim_data.anim_name = right
	
	return anim_data


## 序列化为字典
func to_dict() -> Dictionary[String, StringName]:
	return {
		"left": left,
		"right": right,
		"up": up,
		"down": down,
		"any": any,
	}
