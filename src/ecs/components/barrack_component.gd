@tool
extends Node2D
class_name BarrackComponent
## 兵营组件
##
## BarrackComponent 可以使实体生成士兵并管理士兵列表


@export var disabled: bool = false
## 最小集结范围
@export var rally_min_range: float = 0:
	set(value):
		rally_min_range = value
		queue_redraw()
## 最大集结范围
@export var rally_max_range: float = 300:
	set(value):
		rally_max_range = value
		queue_redraw()
## 集结点位置
@export var rally_center_position := Vector2.ZERO:
	set(value):
		rally_center_position = value
		queue_redraw()
## 集结点半径
@export var rally_radius: float = 30
@export var rally_sfx: AudioGroup = null
## 士兵场景名称
@export var soldier: String = ""
## 生成士兵间隔（秒）
@export var spawn_time: float = 10
## 士兵生成偏移
@export var spawn_offsets: OffsetGroup = null:
	set(value):
		spawn_offsets = value
		if Engine.is_editor_hint():
			U.connect_offset_group_changed(spawn_offsets, _on_spawn_offsets_changed)
		queue_redraw()
## 最大士兵数量
@export var max_soldiers: int = 3
## 生成士兵播放的动画
@export var animation: AnimationGroup = null
## 生成士兵延迟
@export var delay: float = 0
## 生成士兵播放的音效
@export var sfx: AudioGroup = null


## 时间戳（秒）
var ts: float = 0
var is_first_update: bool = true
## 上一次士兵数量
var last_soldier_count: int = C.UNSET
var soldier_group: EntityGroup = null
var last_soldier_pos_list := PackedVector2Array()
var last_blocked_id_list: Array[PackedInt32Array] = []


func _ready() -> void:
	if Engine.is_editor_hint():
		U.connect_offset_group_changed(spawn_offsets, _on_spawn_offsets_changed)
	else:
		soldier_group = EntityGroup.new()
		add_child(soldier_group)


func _on_spawn_offsets_changed() -> void:
	queue_redraw()


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


func new_rally_center_position(
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
		var formation_position: Vector2 = to_formation_position(rally_center_position, max_soldiers, i)
		s_rally_c.new_rally_position(formation_position, is_force, rally_center_position, false)
		
		var melee_c: MeleeComponent = s.get_node_or_null(C.CN_MELEE)
		if melee_c:
			melee_c.origin_pos = formation_position
	

## 将位置转换为阵型位置
func to_formation_position(pos: Vector2, count: int, idx: int) -> Vector2:
	if count == 1:
		return pos
		
	var a: float = 2 * PI / count
	var angle: float = (idx - 1) * a - C.HALF_PI
	
	return U.point_on_circle(
		pos, rally_radius, angle
	)
