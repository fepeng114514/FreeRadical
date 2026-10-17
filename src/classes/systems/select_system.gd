extends System
class_name SelectSystem
## 选择实体系统。
##
## [SelectSystem] 负责处理选择实体的逻辑等。


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("select_entity"):
		SelectManager.select_position = InputManager.mouse_global_position
		SelectManager.is_selecting = true
		

func _on_update(_delta: float) -> void:
	if not SelectManager.is_selecting:
		return
		
	if SelectManager.selected_entity:
		_deselect()
	else:
		var mouse_global_position: Vector2 = InputManager.mouse_global_position
		for entity: Entity in EntityManager.get_component_entity_group(Enums.ComponentFlag.SELECT):
			var select_c: SelectComponent = entity.get_node_or_null(Constants.SELECT_COMPONENT_NODE_PATH)
			if not select_c.is_click_at_global_select_rect(mouse_global_position):
				continue
			
			_select(entity)

	SelectManager.is_selecting = false

		
## 选择实体。
func _select(entity: Entity) -> void:
	Log.debug("选择实体: %s%s" % [entity, entity.global_position])
	SelectManager.selected_entity = entity
	SelectManager.select_mode = SelectManager.SelectMode.NONE
	
	var rally_c: RallyComponent = entity.get_node_or_null(Constants.RALLY_COMPONENT_NODE_PATH)
	if rally_c and rally_c.config.can_select_rally:
		SelectManager.select_mode = SelectManager.SelectMode.RALLY
		
	SelectManager.entity_selected.emit(entity)

	entity.tree_exiting.connect(_on_entity_tree_exiting)


## 取消选择实体。
func _deselect() -> void:
	if SelectManager.selected_entity:
		_process_select_mode()

	SelectManager.select_mode = SelectManager.SelectMode.NONE
	SelectManager.selected_entity.tree_exiting.disconnect(_on_entity_tree_exiting)
	SelectManager.selected_entity = null
	SelectManager.entity_deselected.emit()


func _process_select_mode() -> void:
	match SelectManager.select_mode:
		SelectManager.SelectMode.RALLY:
			var rally_c: RallyComponent = SelectManager.selected_entity.get_node_or_null(
				Constants.RALLY_COMPONENT_NODE_PATH
			)
			rally_c.new_rally_global_position(SelectManager.selected_entity, InputManager.mouse_global_position, true)
		SelectManager.SelectMode.BARRACK_RALLY:
			var entity_global_position: Vector2 = SelectManager.selected_entity.global_position
			var mouse_global_position: Vector2 = InputManager.mouse_global_position
			var barrack_c: BarrackComponent = SelectManager.selected_entity.get_node_or_null(
				Constants.BARRACK_COMPONENT_NODE_PATH
			)
			var rally_max_range: float = barrack_c.config.rally_max_range
			var rally_min_range: float = barrack_c.config.rally_min_range
	
			if MathUtils.is_in_ellipse_ring(
				entity_global_position,
				mouse_global_position,
				rally_min_range,
				rally_max_range
			):
				barrack_c.set_all_rally_center_global_position(mouse_global_position, true)
			else:
				var angle: float = entity_global_position.angle_to_point(mouse_global_position)
				
				var rally_center_global_position: Vector2 = entity_global_position
				if MathUtils.is_in_ellipse(
					entity_global_position,
					mouse_global_position,
					rally_min_range
				):
					rally_center_global_position = MathUtils.get_point_on_ellipse(entity_global_position, rally_min_range, angle)
				else:
					rally_center_global_position = MathUtils.get_point_on_ellipse(
						entity_global_position,
						rally_max_range,
						angle
					)
				barrack_c.set_all_rally_center_global_position(rally_center_global_position, true)


func _on_entity_tree_exiting() -> void:
	SelectManager.selected_entity = null
	SelectManager.entity_deselected.emit()