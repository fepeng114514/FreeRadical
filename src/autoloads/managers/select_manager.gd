extends Node2D


var select_mode: C.SelectMode = C.SelectMode.NONE
var selected_entity: Entity = null


func _ready() -> void:
	S.select_entity.connect(_on_select)
	S.deselect_entity.connect(_on_deselect)


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var click_pos: Vector2 = InputMgr.mouse_global_position
		
		var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
		var query := PhysicsPointQueryParameters2D.new()
		query.position = click_pos
		query.collide_with_areas = true
		
		var results: Array[Dictionary] = space_state.intersect_point(query)
		
		if results.size() > 0:
			S.select_entity.emit(results[0].collider.get_parent())
			return
		
		S.deselect_entity.emit()


func _on_select(e: Entity) -> void:
	e._on_select()
	select_mode = C.SelectMode.NONE

	Log.debug("选择实体: %s%s" % [e, e.global_position])
	e.selected = true
	selected_entity = e
	
	var rally_c: RallyComponent = e.get_c(C.CN_RALLY)
	if rally_c and rally_c.can_select_rally:
		select_mode = C.SelectMode.RALLY
	

func _on_deselect() -> void:
	if not U.is_valid_entity(selected_entity):
		select_mode = C.SelectMode.NONE
		return
	
	match select_mode:
		C.SelectMode.RALLY:
			var rally_c: RallyComponent = selected_entity.get_c(
				C.CN_RALLY
			)
			rally_c.new_rally(InputMgr.mouse_global_position)
		C.SelectMode.BARRACK_RALLY:
			var barrack_c: BarrackComponent = selected_entity.get_c(
				C.CN_BARRACK
			)

			var to_mouse_dist: float = selected_entity.global_position.distance_to(
				InputMgr.mouse_global_position
			)

			if (
					to_mouse_dist <= barrack_c.rally_max_range
					and to_mouse_dist >= barrack_c.rally_min_range
				):
				barrack_c.new_rally(InputMgr.mouse_global_position)
			else:
				var direction_to: Vector2 = selected_entity.global_position.direction_to(
						InputMgr.mouse_global_position
					) 

				if to_mouse_dist >= barrack_c.rally_max_range:
					var rally_pos: Vector2 = (
						direction_to
						* barrack_c.rally_max_range 
						+ selected_entity.global_position
					)
					
					barrack_c.new_rally(rally_pos)
				else:
					var rally_pos: Vector2 = (
						direction_to
						* barrack_c.rally_min_range 
						+ selected_entity.global_position
					)
					
					barrack_c.new_rally(rally_pos)

	select_mode = C.SelectMode.NONE
