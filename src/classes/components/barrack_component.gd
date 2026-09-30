@tool
extends Component
class_name BarrackComponent
## 兵营组件。
##
## BarrackComponent 可以使实体生成士兵，同时也可以管理士兵列表。


@export var config: BarrackComponentNodeConfig = null:
	set(v): 
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()

## 是否禁用。
@export var disabled: bool = false

@export_group("Rally")
## 最小集结范围。
@export var rally_min_range: float = 0.0
## 最大集结范围。
@export var rally_max_range: float = 300
## 集结点全局位置。
@export var rally_center_global_position := Vector2.ZERO
## 集结点半径，影响士兵与集结点之间的距离。
@export var rally_radius: float = 30.0
## 集结音效组。
@export var rally_sfx: AudioGroup = null

@export_group("Spawn")
## 士兵场景路径。
@export_file("*.tscn") var soldier_scene: String = ""
## 生成士兵间隔（秒）。
@export var spawn_interval: float = 10.0
## 士兵生成偏移组。
@export var spawn_offsets: OffsetGroup = null
## 最大士兵数量。
@export var max_soldier_count: int = 3
## 生成士兵播放的动画。
@export var animation: AnimationGroup = null
## 生成士兵延迟（秒），用于在动画播放到特定帧后生成士兵。
@export var delay: float = 0.0
## 生成士兵播放的音效。
@export var sfx: AudioGroup = null

## 时间戳（秒）
var time_stamp: float = 0.0
## 士兵列表。
var soldier_list: Array[Entity] = []
## 上一次生成的士兵数量。
var last_soldier_count: int = 0
## 上一次生成的士兵列表。
var last_soldier_list: Array[Entity] = []


func _draw() -> void:
	if DebugManager.draw_offset_enabled:
		if spawn_offsets:
			spawn_offsets.draw_offset_group(self)
		
	if DebugManager.draw_range_enabled:
		Utils.draw_range_ellipse(self, position, rally_min_range, rally_max_range, Color(0.201, 0.431, 1.0, 0.2))

	if DebugManager.draw_point_enabled:
		var rally_center_position: Vector2 = to_local(rally_center_global_position)
		draw_circle(
			rally_center_position,
			9,
			Color.BLUE, 
			true
		)
		draw_line(
			rally_center_position, 
			position, 
			Color.BLUE, 
			2
		)

		for i: int in max_soldier_count:
			var formation_position: Vector2 = to_formation_position(rally_center_position, max_soldier_count, i)
			draw_circle(
				formation_position,
				3,
				Color.BLUE, 
				true
			)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = super()

	for warning in TowerRecord.get_not_found_configuration_warnings(parent):
		warnings.append(warning)

	return warnings


## 设置新集结点全局位置。
func set_rally_center_global_position(
		center_global_position: Vector2, 
		is_forced: bool = false,
		play_sfx: bool = true
	) -> void:
	if play_sfx:
		AudioManager.play_sfx(rally_sfx)
		
	rally_center_global_position = center_global_position
	var soldier_size: int = soldier_list.size()
	
	for soldier_index: int in soldier_size:
		var soldier: Entity = soldier_list[soldier_index]
		var soldier_rally_c: RallyComponent = soldier.get_node_or_null(Constants.CN_RALLY)
		var formation_position: Vector2 = to_formation_position(rally_center_global_position, soldier_size, soldier_index)
		soldier_rally_c.new_rally_global_position(soldier, formation_position, is_forced, rally_center_global_position, false)
		
		var melee_c: MeleeComponent = soldier.get_node_or_null(Constants.CN_MELEE)
		if melee_c:
			melee_c.original_global_position = formation_position
	

## 将位置转换为阵型位置。
func to_formation_position(center_position: Vector2, count: int, index: int) -> Vector2:
	if count == 1:
		return center_position
		
	var angle_step: float = 2 * PI / count
	var angle: float = (index - 1) * angle_step - Constants.HALF_PI
	
	return MathUtils.get_point_on_ellipse(center_position, rally_radius, angle)
