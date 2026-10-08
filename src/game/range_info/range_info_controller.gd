extends Control
class_name RangeInfoController
## 负责显示和隐藏范围信息


@export_group("Ref")
@export var skill_range_info_scene: PackedScene = null
@export var melee_range_info_scene: PackedScene = null
@export var barrack_rally_range_info_scene: PackedScene = null

var selected_entity: Entity = null
var size_tween_dict: Dictionary[RangeInfo, Tween] = {}


func _ready() -> void:
	SelectManager.entity_selected.connect(_show)
	SelectManager.entity_deselected.connect(_hide)


func _process(_delta: float) -> void:
	if not selected_entity:
		_hide()
		return

	for info: RangeInfo in get_children():
		if info.is_hidden:
			continue

		info._update()

	
func _show(entity: Entity) -> void:
	for info: RangeInfo in get_children():
		info.queue_free()

	selected_entity = entity

	var skill_c: SkillComponent = selected_entity.get_node_or_null(Constants.SKILL_COMPONENT_NODE_PATH)
	if skill_c:
		var first_skill: Skill = skill_c.get_child(0)
		if first_skill.config.searcher:
			_create_range_info_circle(skill_range_info_scene, entity)

	var tower_c: TowerComponent = selected_entity.get_node_or_null(Constants.TOWER_COMPONENT_NODE_PATH)
	if tower_c:
		for sub_entity: Entity in tower_c.get_children():
			var sub_entity_skill_c: SkillComponent = sub_entity.get_node_or_null(Constants.SKILL_COMPONENT_NODE_PATH)
			if not sub_entity_skill_c:
				continue

			var first_skill: Skill = sub_entity_skill_c.get_child(0)
			if first_skill.config.searcher:
				_create_range_info_circle(skill_range_info_scene, sub_entity, entity)

	var melee_c: MeleeComponent = selected_entity.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
	if melee_c:
		if melee_c.is_blocker:
			_create_range_info_circle(melee_range_info_scene, entity)

	var barrack_c: BarrackComponent = selected_entity.get_node_or_null(Constants.BARRACK_COMPONENT_NODE_PATH)
	if barrack_c:
		_create_range_info_circle(barrack_rally_range_info_scene, entity)

		var barrack_record: BarrackRecord = selected_entity.get_node_or_null(Constants.BARRACK_RECORD_NODE_PATH)
		var soldier_list: Array[Entity] = barrack_record.soldier_list
		if soldier_list:
			var soldier: Entity = soldier_list[0]
			var soldier_melee_c: MeleeComponent = soldier.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
			if soldier_melee_c:
				_create_range_info_circle(melee_range_info_scene, soldier, entity)

	
func _hide() -> void:
	for info: RangeInfo in get_children():
		info._hide()


func _create_range_info_circle(info_scene: PackedScene, target_entity: Entity, target_source: Entity = null) -> void:
	var info: RangeInfo = info_scene.instantiate()
	info.target_entity = target_entity
	info.target_source = target_source
	add_child(info)
