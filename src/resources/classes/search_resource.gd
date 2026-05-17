@tool
extends Resource
class_name SearchResource


@export var center_offsets: OffsetGroup = null:
	set(value):
		center_offsets = value
		if Engine.is_editor_hint():
			U.connect_resource_changed(center_offsets, emit_changed)
			emit_changed()
## 最小半径
@export var min_radius: float = 0:
	set(value):
		min_radius = value
		if Engine.is_editor_hint():
			emit_changed()
## 最大半径
@export var max_radius: float = 0:
	set(value):
		max_radius = value
		if Engine.is_editor_hint():
			emit_changed()
## 最大搜索数量
@export var max_search: int = C.UNSET
## 搜索模式
@export var search_mode: C.SearchMode = C.SearchMode.ENEMY_MAX_PROGRESS
## 标识
@export var flags: C.Flag = C.Flag.NONE
## 不可搜索的目标的标识
@export var bans: int = 0
## 可搜索的目标的场景名称列表
@export var whitelist := PackedStringArray()
## 不可搜索的目标的场景名称列表
@export var blacklist := PackedStringArray()


func search_targets(e: Entity, center: Vector2, filter: = Callable()) -> Array[Entity]:
	if center_offsets:
		var center_offset: Vector2 = center_offsets.get_offset_for_point(e.global_position, e.look_point)
		center += center_offset

	var targets: Array[Entity] = EntityMgr.search_targets(
		search_mode, 
		center, 
		max_radius, 
		min_radius, 
		flags, 
		bans,
		filter
	)
	if U.is_valid_number(max_search):
		targets.resize(max_search)

	return targets


func draw(drawer: CanvasItem, center: Vector2) -> void:
	if center_offsets:
		U.draw_range_circle(drawer, center + center_offsets.right, min_radius, max_radius)
		U.draw_offset_group(drawer, center_offsets)
	else:
		U.draw_range_circle(drawer, center, min_radius, max_radius)
