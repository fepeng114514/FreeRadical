@abstract
@tool
extends Resource
class_name InfluenceResource
## 影响资源基类。
##
## InfluenceResource 用于定义如何影响目标，例如治疗、造成伤害、给予状态效果等。[br]
## 影响资源可以是范围影响，也可以是单个实体影响。


@export_group("Extra")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var extra_enable: bool = false
## 击中目标给予的状态效果
@export var mods := PackedStringArray()
## 击中目标给予的持续状态效果
@export var auras := PackedStringArray()
## 击中目标时创建的实体场景名称列表。
@export var payloads := PackedStringArray()

#region 范围影响
@export_group("Area")
## 是否启用范围影响。
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var area_enable: bool = false
## 搜索资源。
@export var search: SearchResource = null:
	set(v): 
		search = v
		if Engine.is_editor_hint():
			U.connect_resource_changed(search, emit_changed)
			emit_changed()
## 是否可以多次影响敌人。
@export var can_influence_multiple: bool = false
## 是否随距离衰减。
@export var falloff_enabled: bool = false
#endregion


func _init() -> void:
	if Engine.is_editor_hint():
		U.connect_resource_changed(search, emit_changed)


@warning_ignore_start("unused_parameter")
## 每次影响实体时调用。
func _take(source: Entity, target: Entity, source_skill_type: Skill.Type, is_area: bool) -> void: pass
@warning_ignore_restore("unused_parameter")


## 对实体造成影响。
func take_influence(source: Entity, base_target: Entity, search_center: Vector2, source_skill_type: Skill.Type = Skill.Type.NONE, search_filter := Callable()) -> Array[Entity]:
	var targets: Array[Entity] = [null]

	if area_enable:
		targets = search.search_targets(source, search_center, search_filter)
	else:
		targets[0] = base_target

	var source_id: int = source.id

	for target: Entity in targets:
		var target_id: int = target.id

		_take(source, target, source_skill_type, area_enable)

		if extra_enable:
			EntityMgr.create_mods(target_id, mods, source_id)
			EntityMgr.create_auras(target_id, auras, source_id)
			EntityMgr.create_entities_at_pos(payloads, target.global_position)

	return targets


## 绘制影响范围。
func draw(drawer: CanvasItem, center: Vector2) -> void:
	if search:
		search.draw(drawer, center)
