@tool
extends Resource
class_name SearchResource


@export var center_offsets: OffsetGroup = null:
	set(v): 
		center_offsets = v
		if Engine.is_editor_hint():
			U.connect_resource_changed(center_offsets, emit_changed)
			emit_changed()
## 最小半径
@export var min_radius: float = 0.0:
	set(v): 
		min_radius = v
		if Engine.is_editor_hint():
			emit_changed()
## 最大半径
@export var max_radius: float = 0.0:
	set(v): 
		max_radius = v
		if Engine.is_editor_hint():
			emit_changed()
## 最大搜索数量
@export var max_search: int = C.UNSET
## 搜索模式
@export var search_mode: C.SearchMode = C.SearchMode.ENEMY_MAX_PROGRESS
@export var interact_policy: InteractPolicy = null


func search_targets(e: Entity, center: Vector2, filter: = Callable()) -> Array[Entity]:
	if center_offsets:
		var center_offset: Vector2 = center_offsets.get_offset_for_point(e.global_position, e.look_point)
		center += center_offset

	var targets: Array[Entity] = EntityMgr.search_targets(
		search_mode, 
		center, 
		max_radius, 
		min_radius, 
		interact_policy.flags if interact_policy else 0, 
		interact_policy.bans if interact_policy else 0,
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
