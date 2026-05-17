@tool
extends Resource
class_name InfluenceResource


@export_group("Extra")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var extra_enable: bool = false
## 击中目标给予的状态效果
@export var mods := PackedStringArray()
@export var auras := PackedStringArray()
@export var payloads := PackedStringArray()

#region 范围影响
@export_group("Area")
## 是否启用范围影响
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var area_enable: bool = false
@export var search: SearchResource = null:
	set(value):
		search = value
		if Engine.is_editor_hint():
			U.connect_resource_changed(search, emit_changed)
			emit_changed()
## 是否可以多次影响敌人
@export var can_influence_multiple: bool = false
#endregion


func _init() -> void:
	if Engine.is_editor_hint():
		U.connect_resource_changed(search, emit_changed)


@warning_ignore_start("unused_parameter")
func _take(source: Entity, target: Entity) -> void: pass
@warning_ignore_restore("unused_parameter")


func take(source: Entity, base_target: Entity, search_center: Vector2, search_filter := Callable()) -> Array[Entity]:
	var targets: Array[Entity] = [null]

	if area_enable:
		targets = search.search_targets(source, search_center, search_filter)
	else:
		targets[0] = base_target

	var source_id: int = source.id

	for target: Entity in targets:
		var target_id: int = target.id

		_take(source, target)

		if extra_enable:
			EntityMgr.create_mods(target_id, mods, source_id)
			EntityMgr.create_auras(mods, target_id)
			EntityMgr.create_entities_at_pos(payloads, target.global_position)

	return targets


func draw(drawer: CanvasItem, center: Vector2) -> void:
	if search:
		search.draw(drawer, center)
