@tool
@icon("res://assets/dpi_textures/at-icons/node2d/location.svg")
extends Component
class_name RallyComponent
## 集结组件。
##
## RallyComponent 可以使实体移动到指定位置，并支持阵型排列


const navigation_agent_path: NodePath = ^"NavigationAgent2D"


@export var config: RallyComponentNodeConfig = null:
	set(v): 
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()

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
## 是否强制集结。
var is_force_rally: bool = false
## 集结中心全局位置。
var rally_center_global_position := Vector2.ZERO

## 血条节点引用。
@onready var navigation_agent: NavigationAgent2D = get_node_or_null(navigation_agent_path)


func _ready() -> void:
	super()

	child_order_changed.connect(_on_child_order_changed)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = super()

	if not navigation_agent:
		warnings.append("请增加一个 NavigationAgent2D 子节点用作导航，否则实体无法移动到指定位置。")

	return warnings


## 设置新的集结全局位置。
func new_rally_global_position(
		p_entity: Entity,
		new_global_position: Vector2, 
		is_forced: bool = false,
		center: Vector2 = new_global_position,
		play_sfx: bool = true
	) -> void:
	is_force_rally = is_forced
	if is_forced:
		if p_entity.state & Entity.State.WAITING:
			p_entity.state |= Entity.State.INTERRUPT_WAIT
	
	arrived = false
	navigation_agent.target_position = new_global_position
	rally_center_global_position = center
	
	if play_sfx:
		AudioManager.play_sfx(motion_sfx)


func _on_child_order_changed() -> void:
	navigation_agent = get_node_or_null(navigation_agent_path) 
	update_configuration_warnings()
