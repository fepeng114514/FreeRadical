extends RangeInfo


func _update() -> void:
	var skill_c: SkillComponent = target_entity.get_node_or_null(Constants.SKILL_COMPONENT_NODE_PATH)
	var first_skill := skill_c.get_child(0) as SearchSkill
	if not first_skill:
		return

	var searcher: Searcher = first_skill.config.searcher
	global_position = first_skill.get_search_global_position(target_entity)

	min_range_circle._show(searcher.min_radius)
	max_range_circle._show(searcher.max_radius)
