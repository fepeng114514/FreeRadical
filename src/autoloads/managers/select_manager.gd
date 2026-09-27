extends Node
## 选择管理器。
## 
## 负责管理选择与相关操作。


## 选择模式枚举。
enum SelectMode {
	## 选择模式：无
	NONE,
	## 选择模式：集结
	RALLY,
	## 选择模式：兵营集结
	BARRACK_RALLY,
	## 选择模式：错误
	ERROR,
}


@warning_ignore_start("unused_signal")
## 选择实体时发出。
signal entity_selected(entity: Entity)
## 取消选择实体时发出。
signal entity_deselected
@warning_ignore_restore("unused_signal")


## 选择模式。
var select_mode: SelectMode = SelectMode.NONE
## 选中的实体。
var selected_entity: Entity = null


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("select_entity"):
		try_select()


## 尝试选择实体。
func try_select() -> void:
	if selected_entity:
		if selected_entity:
			selected_entity.selected = false
		
		_deselect()
	else:
		var mouse_global_position: Vector2 = InputManager.mouse_global_position
		for entity: ECSEntity in ECSEntityManager.get_valid_entities():
			var select_c: SelectComponent = entity.get_node_or_null(Constants.CN_SELECT)
			if not select_c:
				continue
			
			if not select_c.is_click_at_global_select_rect(mouse_global_position):
				continue
			
			_select(entity)

		
## 选择实体。
func _select(entity: Entity) -> void:
	Log.debug("选择实体: %s%s" % [entity, entity.global_position])
	entity.selected = true
	selected_entity = entity
	select_mode = SelectMode.NONE
	
	var rally_c: RallyComponent = entity.get_node_or_null(Constants.CN_RALLY)
	if rally_c and rally_c.can_select_rally:
		select_mode = SelectMode.RALLY
		
	entity_selected.emit(entity)

	entity.tree_exiting.connect(_on_entity_tree_exiting.bind(entity))


func _on_entity_tree_exiting(_entity: Entity) -> void:
	selected_entity = null
	entity_deselected.emit()


## 取消选择实体。
func _deselect() -> void:
	if selected_entity:
		_process_select_mode()

	select_mode = SelectMode.NONE
	selected_entity = null
	entity_deselected.emit()


func _process_select_mode() -> void:
	match select_mode:
		SelectMode.RALLY:
			var rally_c: RallyComponent = selected_entity.get_node_or_null(
				Constants.CN_RALLY
			)
			rally_c.new_rally_global_position(selected_entity, InputManager.mouse_global_position, true)
		SelectMode.BARRACK_RALLY:
			var entity_global_position: Vector2 = selected_entity.global_position
			var mouse_global_position: Vector2 = InputManager.mouse_global_position
			var barrack_c: BarrackComponent = selected_entity.get_node_or_null(
				Constants.CN_BARRACK
			)
			var rally_max_range: float = barrack_c.rally_max_range
			var rally_min_range: float = barrack_c.rally_min_range
	
			if MathUtils.is_in_ellipse_ring(
				entity_global_position,
				mouse_global_position,
				rally_min_range,
				rally_max_range
			):
				barrack_c.set_rally_center_global_position(mouse_global_position, true)
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
				barrack_c.set_rally_center_global_position(rally_center_global_position, true)
