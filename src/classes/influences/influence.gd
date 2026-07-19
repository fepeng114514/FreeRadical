@tool
extends Resource
class_name Influence
## 影响资源，基类。
##
## Influence 用于定义如何影响目标，例如治疗、造成伤害、给予状态效果等。


## 取值模式枚举。
enum GetValueMode {
	## 取值模式：随机值，根据范围随机取值。
	RANDOM,
	## 取值模式：根据距离衰减。
	RADIAL_FALLOFF,
}

## 最小影响值。
@export var min_value: float = 0.0
## 最大影响值。
@export var max_value: float = 0.0
## 取值模式。
@export var get_value_mode: GetValueMode = GetValueMode.RANDOM

@export_group("Extra")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var extra_enable: bool = false
## 给予的状态效果路径列表。
@export_file("*.tscn") var mods := PackedStringArray()
## 给予的持续状态效果路径列表。
@export_file("*.tscn") var auras := PackedStringArray()
## 创建的实体场景路径列表。
@export_file("*.tscn") var payloads := PackedStringArray()

@export_group("Area")
## 是否启用范围影响。
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var area_enable: bool = false
## 搜索资源，用于搜索目标。
@export var searcher: Searcher = null:
	set(v): 
		searcher = v
		if Engine.is_editor_hint():
			U.connect_resource_changed(searcher, emit_changed)
			emit_changed()
## 是否可以多次影响目标。
@export var can_influence_multiple: bool = false

## 覆盖的影响值，用于使用外部的影响值，会覆盖后续计算的影响值。
var override_value: float = C.UNSET


func _init() -> void:
	resource_local_to_scene = true

	if Engine.is_editor_hint():
		U.connect_resource_changed(searcher, emit_changed)


@warning_ignore_start("unused_parameter")
## 每次影响实体时调用。
func _take(source: Entity, target: Entity, is_area: bool) -> void: pass
@warning_ignore_restore("unused_parameter")


## 对实体造成影响。
func take_influence(source: Entity, base_target: Entity, search_center: Vector2, search_filter := Callable()) -> Array[Entity]:
	var targets: Array[Entity] = [null]
	if area_enable:
		targets = searcher.search_targets(search_center, source, search_filter)
	else:
		targets[0] = base_target

	var source_id: int = source.id
	
	for target: Entity in targets:
		var target_id: int = target.id

		_take(source, target, area_enable)

		if extra_enable:
			EntityMgr.create_mods(target_id, mods, source_id)
			EntityMgr.create_auras(target_id, auras, source_id)
			EntityMgr.create_entities_at_pos(payloads, target.global_position)

	return targets


## 绘制影响范围。
func draw(drawer: CanvasItem, center: Vector2) -> void:
	if searcher:
		searcher.draw(drawer, center)


func get_value(source: Entity, target: Entity) -> float:
	if U.is_valid_number(override_value):
		return override_value
		
	match get_value_mode:
		GetValueMode.RANDOM:
			return randf_range(min_value, max_value)
		GetValueMode.RADIAL_FALLOFF:
			return U.get_radial_falloff(
				source.global_position, 
				target.global_position, 
				searcher.min_radius,
				searcher.max_radius,
				min_value,
				max_value
			)
		
	return 0
