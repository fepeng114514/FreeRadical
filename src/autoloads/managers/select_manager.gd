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
signal entity_selected(e: Entity)
## 取消选择实体时发出。
signal entity_deselected
@warning_ignore_restore("unused_signal")


## 选择模式。
var select_mode: SelectMode = SelectMode.NONE
## 选中的实体。
var selected_entity: Entity = null
## 鼠标实体。
var cursor: Entity = null
var searcher: Searcher = null
var is_selected: bool = false


func _load() -> void:
	_clear()

	searcher = Searcher.new()
	searcher.max_radius = 99999
	searcher.sort_mode = Searcher.SortMode.ID
	searcher.search_group = Searcher.SearchGroup.ENTITY

	is_selected = false


func _clear() -> void:
	searcher = null
	cursor = null


func _unhandled_input(event: InputEvent) -> void:
	if is_selected:
		return

	if event.is_action_pressed("select_entity"):
		is_selected = true
		
		await SystemMgr.update_system_finished
		try_select()

		is_selected = false


## 尝试选择实体。
func try_select() -> void:
	if not searcher:
		return
	
	if selected_entity:
		if U.is_valid_entity(selected_entity):
			selected_entity.selected = false
		
		_deselect()
	else:
		var target: Entity = searcher.search_target(
			InputMgr.mouse_global_position,
			null,
			func(entity: Entity) -> bool:
				var ui_c: UIComponent = entity.get_node_or_null(C.CN_UI)
				if not ui_c:
					return false
				
				return ui_c.is_click_at(
					entity.global_position,
					InputMgr.mouse_global_position
				)
		)
		if target:
			_select(target)
		

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
		
	entity_selected.emit(e)


## 取消选择实体。
func _deselect() -> void:
	if U.is_valid_entity(selected_entity):
		_process_select_mode()

	select_mode = SelectMode.NONE
	selected_entity = null
	entity_deselected.emit()


func _process_select_mode() -> void:
	match select_mode:
		SelectMode.RALLY:
			var rally_c: RallyComponent = selected_entity.get_node_or_null(
				C.CN_RALLY
			)
			rally_c.new_rally_position(selected_entity, InputMgr.mouse_global_position, true)
		SelectMode.BARRACK_RALLY:
			var e_global_pos: Vector2 = selected_entity.global_position
			var mouse_global_pos: Vector2 = InputMgr.mouse_global_position
			var barrack_c: BarrackComponent = selected_entity.get_node_or_null(
				C.CN_BARRACK
			)
			var rally_max_range: float = barrack_c.rally_max_range
			var rally_min_range: float = barrack_c.rally_min_range
	
			if U.is_in_ellipse_ring(
				e_global_pos,
				mouse_global_pos,
				rally_min_range,
				rally_max_range
			):
				barrack_c.set_rally_center_position(mouse_global_pos, true)
			else:
				var angle: float = e_global_pos.angle_to_point(mouse_global_pos)
				
				var rally_center_position: Vector2 = e_global_pos
				if U.is_in_ellipse(
					e_global_pos,
					mouse_global_pos,
					rally_min_range
				):
					rally_center_position = U.get_point_on_ellipse(e_global_pos, rally_min_range, angle)
				else:
					rally_center_position = U.get_point_on_ellipse(
						e_global_pos,
						rally_max_range,
						angle
					)
				barrack_c.set_rally_center_position(rally_center_position, true)
