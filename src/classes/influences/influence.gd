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
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var extra_enabled: bool = false
## 给予的状态效果路径列表。
@export_file("*.tscn") var mods: PackedStringArray
## 给予的持续状态效果路径列表。
@export_file("*.tscn") var auras: PackedStringArray
## 创建的实体场景路径列表。
@export_file("*.tscn") var payloads: PackedStringArray

@export_group("Area")
## 是否启用范围影响。
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var area_enabled: bool = false
## 搜索资源，用于搜索目标。
@export var searcher: Searcher = null:
	set(v): 
		Utils.rebind_changed(searcher, v, emit_changed)
		searcher = v
		emit_changed()

## 覆盖的影响值，用于使用外部的影响值，会覆盖后续计算的影响值。
var override_value: float = Constants.UNSET


var _init_connect_property_signals: Dictionary[String, Callable] = {
	"searcher": emit_changed,
}


func _init() -> void:
	resource_local_to_scene = true
	
	Utils.connect_property_signals(self, _init_connect_property_signals)


@warning_ignore_start("unused_parameter")
## 每次影响实体时调用。
func _take(source: Entity, target: Entity, is_area: bool) -> void: pass
@warning_ignore_restore("unused_parameter")


## 对实体造成影响。
func take_influence(source: Entity, base_target: Entity, search_center: Vector2) -> Array[Entity]:
	var targets: Array[Entity] = [null]
	if area_enabled:
		targets = searcher.search_targets(search_center, source)
	else:
		targets[0] = base_target

	var source_id: int = source.id
	
	for target: Entity in targets:
		var target_id: int = target.id

		_take(source, target, area_enabled)

		if extra_enabled:
			EntityManager.create_mods(target_id, mods, source_id)
			EntityManager.create_auras(target_id, auras, source_id)
			EntityManager.create_entities_at_global_position(payloads, target.global_position)

	return targets


## 绘制影响范围。
func draw_influence_range(drawer: CanvasItem, center: Vector2) -> void:
	if searcher:
		searcher.draw_search_range(drawer, center)


func get_value(source: Entity, target: Entity) -> float:
	if Utils.is_valid_number(override_value):
		return override_value
		
	match get_value_mode:
		GetValueMode.RANDOM:
			return randf_range(min_value, max_value)
		GetValueMode.RADIAL_FALLOFF:
			return MathUtils.get_ellipse_radial_falloff(
				source.global_position, 
				target.global_position, 
				searcher.min_radius,
				searcher.max_radius,
				min_value,
				max_value
			)
		
	return 0
