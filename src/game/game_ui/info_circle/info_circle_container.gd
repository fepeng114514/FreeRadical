extends Control


@export_group("Tween")
## 补间缩放时长
@export var tween_scale_time: float = 0.15

@export_group("Ref")
@export var ranged_min_range_circle: InfoCircle = null
@export var ranged_max_range_circle: InfoCircle = null
@export var rally_min_range_circle: InfoCircle = null
@export var rally_max_range_circle: InfoCircle = null
@export var melee_min_range_circle: InfoCircle = null
@export var melee_max_range_circle: InfoCircle = null

## 所有圆圈
@onready var all_circle: Array[InfoCircle] = [
	ranged_min_range_circle,
	ranged_max_range_circle,
	rally_min_range_circle,
	rally_max_range_circle,
	melee_min_range_circle,
	melee_max_range_circle,
]

## 选择的实体
var selected_entity: Entity = null



func _ready() -> void:
	SelectMgr.entity_selected.connect(_show)
	SelectMgr.entity_deselected.connect(_hide)
	visible = false
	
	
func _process(_delta: float) -> void:
	if visible:
		if not U.is_valid_entity(selected_entity):
			_hide()
			return
		
		_update()
			

func _show(e: Entity) -> void:
	selected_entity = e
	
	for circle: InfoCircle in all_circle:
		circle.scale = Vector2.ZERO
		circle.visible = false
	
	visible = true
	_update()
	
	
func _hide() -> void:
	visible = false
	selected_entity = null
	
	for circle: InfoCircle in all_circle:
		circle._hide(tween_scale_time)


func _update() -> void:
	var base_position: Vector2 = selected_entity.global_position - ranged_max_range_circle.size / 2
	
	var skill_c: SkillComponent = selected_entity.get_node_or_null(C.CN_SKILL)
	if skill_c:
		var first_ranged_skill: SkillRanged = skill_c.get_child(0) as SkillRanged
		if first_ranged_skill:
			var search: SearchResource = first_ranged_skill.search

			ranged_min_range_circle._show(search.min_radius, base_position, tween_scale_time)
			ranged_max_range_circle._show(search.max_radius, base_position, tween_scale_time)

	var melee_c: MeleeComponent = selected_entity.get_node_or_null(C.CN_MELEE)
	if melee_c:
		if melee_c.is_blocker:
			_show_melee_circle(selected_entity)

	var tower_c: TowerComponent = selected_entity.get_node_or_null(C.CN_TOWER)
	if tower_c:
		if tower_c.get_child_count() > 0:
			var first_entity: Entity = tower_c.get_child(0)
			var f_skill_c: SkillComponent = first_entity.get_node_or_null(C.CN_SKILL)
			var first_ranged_skill: SkillRanged = f_skill_c.get_child(0)
			var search: SearchResource = first_ranged_skill.search
			var pos: Vector2 = base_position + tower_c.show_range_offset
		
			ranged_min_range_circle._show(
				search.min_radius, 
				pos,
				tween_scale_time
			)
			ranged_max_range_circle._show(
				search.max_radius, 
				pos,
				tween_scale_time
			)

	var barrack_c: BarrackComponent = selected_entity.get_node_or_null(C.CN_BARRACK)
	if barrack_c:
		rally_min_range_circle._show(barrack_c.rally_min_range, base_position, tween_scale_time)
		rally_max_range_circle._show(barrack_c.rally_max_range, base_position, tween_scale_time)

		var soldier_list: Array[Entity] = barrack_c.soldier_list

		if soldier_list.size() > 0:
			var first_entity: Entity = soldier_list[0]
			_show_melee_circle(first_entity)


func _show_melee_circle(e: Entity) -> void:
	var melee_c: MeleeComponent = e.get_node_or_null(C.CN_MELEE)
	if not melee_c:
		return
		
	var pos: Vector2 = e.global_position - global_position - melee_max_range_circle.size / 2
	
	var rally_c: RallyComponent = e.get_node_or_null(C.CN_RALLY)
	if rally_c:
		var rally_center_position: Vector2 = rally_c.rally_center_position
		if rally_center_position != Vector2.ZERO:
			pos = rally_center_position - global_position - melee_max_range_circle.size / 2
	
	var search: SearchResource = melee_c.search
	melee_min_range_circle._show(search.min_radius, pos, tween_scale_time)
	melee_max_range_circle._show(search.max_radius, pos, tween_scale_time)
