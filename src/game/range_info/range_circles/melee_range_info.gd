extends RangeInfo


func _update() -> void:
	if target_source:
		var barrack_c: BarrackComponent = target_source.get_node_or_null(C.CN_BARRACK)
		if barrack_c:
			var soldier_list: Array[Entity] = barrack_c.soldier_list
			if soldier_list:
				var soldier: Entity = soldier_list[0]
				var soldier_melee_c: MeleeComponent = soldier.get_node_or_null(C.CN_MELEE)
				if soldier_melee_c:
					target_entity = soldier
					
	if not U.is_valid_entity(target_entity):
		return

	var rally_c: RallyComponent = target_entity.get_node_or_null(C.CN_RALLY)
	if rally_c:
		global_position = rally_c.rally_center_position
	else:
		global_position = target_entity.global_position

	var melee_c: MeleeComponent = target_entity.get_node_or_null(C.CN_MELEE)
	var searcher: Searcher = melee_c.searcher

	min_range_circle._show(searcher.min_radius)
	max_range_circle._show(searcher.max_radius)
