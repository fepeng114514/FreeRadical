extends RangeInfo


func _update() -> void:
	var barrack_c: BarrackComponent = target_entity.get_node_or_null(C.CN_BARRACK)

	global_position = target_entity.global_position

	min_range_circle._show(barrack_c.rally_min_range)
	max_range_circle._show(barrack_c.rally_max_range)
