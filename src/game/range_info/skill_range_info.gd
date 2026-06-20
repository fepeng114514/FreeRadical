extends RangeInfo


func _update() -> void:
	var skill_c: SkillComponent = target_entity.get_node_or_null(C.CN_SKILL)
	var first_skill: Skill = skill_c.get_child(0)
	var search: SearchResource = first_skill.get("search")
	if not search:
		return
		
	global_position = target_entity.global_position

	min_range_circle._show(search.min_radius)
	max_range_circle._show(search.max_radius)
