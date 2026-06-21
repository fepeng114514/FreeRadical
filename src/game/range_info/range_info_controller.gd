extends Control


@export_group("Ref")
@export var skill_range_info_scene: PackedScene = null
@export var melee_range_info_scene: PackedScene = null
@export var barrack_rally_range_info_scene: PackedScene = null

var selected_entity: Entity = null
var size_tween_dict: Dictionary[RangeInfo, Tween] = {}


func _ready() -> void:
	SelectMgr.entity_selected.connect(_show)
	SelectMgr.entity_deselected.connect(_hide)


func _process(_delta: float) -> void:
	if not U.is_valid_entity(selected_entity):
		_hide()
		return

	for info: RangeInfo in get_children():
		if info.is_hidden:
			continue

		info._update()

	
func _show(e: Entity) -> void:
	for info: RangeInfo in get_children():
		info.queue_free()

	selected_entity = e

	var skill_c: SkillComponent = selected_entity.get_node_or_null(C.CN_SKILL)
	if skill_c:
		var first_skill: Skill = skill_c.get_child(0)
		if first_skill.searcher:
			_create_range_info_circle(skill_range_info_scene, e)

	var tower_c: TowerComponent = selected_entity.get_node_or_null(C.CN_TOWER)
	if tower_c:
		for sub_entity: Entity in tower_c.get_children():
			var sub_entity_skill_c: SkillComponent = sub_entity.get_node_or_null(C.CN_SKILL)
			if not sub_entity_skill_c:
				continue

			var first_skill: Skill = sub_entity_skill_c.get_child(0)
			if first_skill.searcher:
				_create_range_info_circle(skill_range_info_scene, sub_entity, e)

	var melee_c: MeleeComponent = selected_entity.get_node_or_null(C.CN_MELEE)
	if melee_c:
		if melee_c.is_blocker:
			_create_range_info_circle(melee_range_info_scene, e)

	var barrack_c: BarrackComponent = selected_entity.get_node_or_null(C.CN_BARRACK)
	if barrack_c:
		_create_range_info_circle(barrack_rally_range_info_scene, e)

		var soldier_list: Array[Entity] = barrack_c.soldier_list
		if soldier_list:
			var soldier: Entity = soldier_list[0]
			var soldier_melee_c: MeleeComponent = soldier.get_node_or_null(C.CN_MELEE)
			if soldier_melee_c:
				_create_range_info_circle(melee_range_info_scene, soldier, e)

	
func _hide() -> void:
	for info: RangeInfo in get_children():
		info._hide()


func _create_range_info_circle(info_scene: PackedScene, target_entity: Entity, target_source: Entity = null) -> void:
	var info: RangeInfo = info_scene.instantiate()
	info.target_entity = target_entity
	info.target_source = target_source
	add_child(info)
