extends RangeInfo


func _update() -> void:
	var skill_c: SkillComponent = target_entity.get_node_or_null(C.CN_SKILL)
	var first_skill: Skill = skill_c.get_child(0)
	var searcher: Searcher = first_skill.get("searcher")
	if not searcher:
		return
		
	global_position = first_skill.get_search_center(target_entity)

	min_range_circle._show(searcher.min_radius)
	max_range_circle._show(searcher.max_radius)
