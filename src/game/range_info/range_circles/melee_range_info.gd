extends RangeInfo


func _update() -> void:
	if target_source:
		var barrack_c: BarrackComponent = target_source.get_node_or_null(Constants.BARRACK_COMPONENT_NODE_PATH)
		if barrack_c:
			var barrack_record: BarrackRecord = target_source.get_node_or_null(Constants.BARRACK_RECORD_NODE_PATH)
			var soldier_list: Array[Entity] = barrack_record.soldier_list
			if soldier_list:
				var soldier: Entity = soldier_list[0]
				var soldier_melee_c: MeleeComponent = soldier.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
				if soldier_melee_c:
					target_entity = soldier
					
	if not target_entity:
		return

	var rally_c: RallyComponent = target_entity.get_node_or_null(Constants.RALLY_COMPONENT_NODE_PATH)
	if rally_c:
		global_position = rally_c.rally_center_global_position
	else:
		global_position = target_entity.global_position

	var melee_c: MeleeComponent = target_entity.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
	var searcher: Searcher = melee_c.config.searcher

	min_range_circle._show(searcher.min_radius)
	max_range_circle._show(searcher.max_radius)
