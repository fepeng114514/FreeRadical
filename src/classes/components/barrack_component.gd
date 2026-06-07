@tool
extends Component
class_name BarrackComponent
## 兵营组件。
##
## BarrackComponent 可以使实体生成士兵并管理士兵列表。


## 是否禁用。
@export var disabled: bool = false
## 最小集结范围。
@export var rally_min_range: float = 0.0:
	set(v): 
		rally_min_range = v
		queue_redraw()
## 最大集结范围。
@export var rally_max_range: float = 300:
	set(v): 
		rally_max_range = v
		queue_redraw()
## 集结点位置。
@export var rally_center_position := Vector2.ZERO:
	set(v): 
		rally_center_position = v
		queue_redraw()
## 集结点半径。
@export var rally_radius: float = 30
## 集结音效组。
@export var rally_sfx: AudioGroup = null
## 士兵场景名称。
@export var soldier: String = ""
## 生成士兵间隔（秒）。
@export var spawn_interval: float = 10
## 士兵生成偏移组。
@export var spawn_offsets: OffsetGroup = null:
	set(v): 
		spawn_offsets = v
		if Engine.is_editor_hint():
			U.connect_resource_changed(spawn_offsets, queue_redraw)
			queue_redraw()
## 最大士兵数量。
@export var max_soldier_count: int = 3
## 生成士兵播放的动画。
@export var animation: AnimationGroup = null
## 生成士兵延迟（秒），用于在动画播放到特定帧后生成士兵。
@export var delay: float = 0.0
## 生成士兵播放的音效。
@export var sfx: AudioGroup = null


## 时间戳（秒）
var ts: float = 0.0
## 士兵组。
var soldier_group: EntityGroup = null
## 上一次生成的士兵数量。
var last_soldier_count: int = 0
## 上一次生成的士兵组。
var last_soldier_group: EntityGroup = null


func _ready() -> void:
	if Engine.is_editor_hint():
		U.connect_resource_changed(spawn_offsets, queue_redraw)
	else:
		soldier_group = EntityGroup.new()
		add_child(soldier_group)


func _draw() -> void:
	if Engine.is_editor_hint():
		U.draw_offset_group(self, spawn_offsets)
		U.draw_range_circle(self, position, rally_min_range, rally_max_range, Color.BLUE)
		
		draw_circle(
			rally_center_position,
			9,
			Color(0.486, 0.294, 1.0, 1.0), 
			true
		)


## 设置新集结点位置。
func set_rally_center_position(
		center_position: Vector2, 
		is_force: bool = false,
		play_sfx: bool = true
	) -> void:
	if play_sfx:
		AudioMgr.play_sfx(rally_sfx)
		
	rally_center_position = center_position
	
	for i: int in soldier_group.get_child_count():
		var s: Entity = soldier_group.get_child(i)
		var s_rally_c: RallyComponent = s.get_node_or_null(C.CN_RALLY)
		var formation_position: Vector2 = to_formation_position(rally_center_position, max_soldier_count, i)
		s_rally_c.new_rally_position(formation_position, is_force, rally_center_position, false)
		
		var melee_c: MeleeComponent = s.get_node_or_null(C.CN_MELEE)
		if melee_c:
			melee_c.origin_pos = formation_position
	

## 将位置转换为阵型位置。
func to_formation_position(pos: Vector2, count: int, idx: int) -> Vector2:
	if count == 1:
		return pos
		
	var a: float = 2 * PI / count
	var angle: float = (idx - 1) * a - C.HALF_PI
	
	return U.point_on_circle(
		pos, rally_radius, angle
	)
