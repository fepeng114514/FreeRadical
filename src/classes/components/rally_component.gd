@tool
@icon("res://assets/dpi_textures/at-icons/node2d/location.svg")
extends Component
class_name RallyComponent
## 集结组件。
##
## RallyComponent 可以使实体移动到指定位置，并支持阵型排列


## 移动速度。
@export var speed: float = 100.0
## 是否可点击集结。
@export var can_select_rally: bool = true
## 移动动画组。
@export var motion_animation: AnimationGroup = null
## 移动音效组。
@export var motion_sfx: AudioGroup = null

## 是否已到达集结位置。
var arrived: bool = false
## 是否强制强制集结。
var is_force_rally: bool = false
## 集结中心位置。
var rally_center_position := Vector2.ZERO

## 血条节点引用。
@onready var navigation_agent: NavigationAgent2D = get_node_or_null("NavigationAgent2D")


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
		
	if not navigation_agent:
		warnings.append("请增加一个 NavigationAgent2D 子节点用作导航。")
		
	return warnings


## 设置新的集结位置。
func new_rally_position(
		pos: Vector2, 
		is_force: bool = false,
		center: Vector2 = pos,
		play_sfx: bool = true
	) -> void:
	is_force_rally = is_force
	arrived = false
	navigation_agent.target_position = pos
	rally_center_position = center
	
	if play_sfx:
		AudioMgr.play_sfx(motion_sfx)
