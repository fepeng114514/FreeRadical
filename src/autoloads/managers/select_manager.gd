extends Node2D
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
## 选择实体信号。
signal select_entity(e: Entity)
## 取消选择实体信号。
signal deselect_entity
@warning_ignore_restore("unused_signal")


## 选择模式。
var select_mode: SelectMode = SelectMode.NONE
## 选中的实体。
var selected_entity: Entity = null
## 鼠标实体。
var cursor: Entity = null


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("select_entity"):
		call_deferred("try_select")


## 尝试选择实体。
func try_select() -> void:
	if selected_entity:
		if U.is_valid_entity(selected_entity):
			selected_entity.selected = false
		
		_deselect()
	else:
		var targets: Array[Entity] = EntityMgr.search_targets(
			C.SearchMode.ENTITY_MAX_ID, 
			InputMgr.mouse_global_position, 
			9999, 
			0, 
			0, 
			0, 
			func(entity: Entity) -> bool:
				var ui_c: UIComponent = entity.get_node_or_null(C.CN_UI)
				if not ui_c:
					return false
				
				return ui_c.is_click_at(
					entity.global_position, 
					InputMgr.mouse_global_position
				)
		)
		if targets:
			var e: Entity = targets[0]

			_select(e)
		

## 选择实体。
func _select(e: Entity) -> void:
	Log.debug("选择实体: %s%s" % [e, e.global_position])
	e.selected = true
	selected_entity = e
	e._on_select()
	select_mode = SelectMode.NONE
	
	var rally_c: RallyComponent = e.get_node_or_null(C.CN_RALLY)
	if rally_c and rally_c.can_select_rally:
		select_mode = SelectMode.RALLY
		
	select_entity.emit(e)


## 取消选择实体。
func _deselect() -> void:
	if U.is_valid_entity(selected_entity):
		match select_mode:
			SelectMode.RALLY:
				var rally_c: RallyComponent = selected_entity.get_node_or_null(
					C.CN_RALLY
				)
				rally_c.new_rally_position(InputMgr.mouse_global_position, true)
			SelectMode.BARRACK_RALLY:
				var barrack_c: BarrackComponent = selected_entity.get_node_or_null(
					C.CN_BARRACK
				)

				var to_mouse_dist: float = selected_entity.global_position.distance_to(
					InputMgr.mouse_global_position
				)

				if (
						to_mouse_dist <= barrack_c.rally_max_range
						and to_mouse_dist >= barrack_c.rally_min_range
					):
					barrack_c.set_rally_center_position(InputMgr.mouse_global_position, true)
				else:
					var direction_to: Vector2 = selected_entity.global_position.direction_to(
							InputMgr.mouse_global_position
						) 
					
					var rally_center_position := Vector2.ZERO
					if to_mouse_dist >= barrack_c.rally_max_range:
						rally_center_position = (
							direction_to
							* barrack_c.rally_max_range 
							+ selected_entity.global_position
						)
					else:
						rally_center_position = (
							direction_to
							* barrack_c.rally_min_range 
							+ selected_entity.global_position
						)
						
					barrack_c.set_rally_center_position(rally_center_position, true)

	select_mode = SelectMode.NONE
	selected_entity = null
	deselect_entity.emit()
