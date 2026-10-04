extends RangeInfo


func _update() -> void:
	var barrack_c: BarrackComponent = target_entity.get_node_or_null(Constants.BARRACK_COMPONENT_NODE_PATH)

	global_position = target_entity.global_position

	min_range_circle._show(barrack_c.config.rally_min_range)
	max_range_circle._show(barrack_c.config.rally_max_range)
