extends System
class_name SelectSystem

var select_type: C.SELECT = C.SELECT.NONE
var selected_entity: Entity = null

func _ready() -> void:
	S.select_entity_s.connect(_on_select)
	S.deselect_entity_s.connect(_on_deselect)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		var mouse_global_position: Vector2 = (
			InputMgr.mouse_global_position
		)
		
		var e: Entity = EntityDB.search_target(
			C.SEARCH.ENTITY_MAX_ID, 
			mouse_global_position, 
			C.UNSET, 
			0, 
			0, 
			0, 
			func(entity: Entity) -> bool:
				if not entity.has_c(C.CN_UI):
					return false

				var ui_c: UIComponent = entity.get_c(C.CN_UI)
				
				return ui_c.is_click_at(
					entity.global_position, 
					mouse_global_position
				)
		)
		
		if not e:
			if U.is_vaild_entity(selected_entity):
				selected_entity.selected = false
				
			S.deselect_entity_s.emit()
			selected_entity = null
			return

		Log.debug("选择实体: %s, %s" % [e, e.global_position])
		e.selected = true
		selected_entity = e
		S.select_entity_s.emit(e)
		return
		
		
func _on_select(e: Entity) -> void:
	if e.has_c(C.CN_RALLY):
		var rally_c: RallyComponent = e.get_c(C.CN_RALLY)
		
		if not rally_c.can_click_rally:
			return
			
		select_type = C.SELECT.RALLY

	if e.has_c(C.CN_BARRACK):
		select_type = C.SELECT.BARRACK_RALLY
	

func _on_deselect() -> void:
	var mouse_global_position: Vector2 = InputMgr.mouse_global_position

	match select_type:
		C.SELECT.RALLY:
			var rally_c: RallyComponent = selected_entity.get_c(C.CN_RALLY)
			rally_c.new_rally(mouse_global_position)
		C.SELECT.BARRACK_RALLY:
			var barrack_c: BarrackComponent = selected_entity.get_c(C.CN_BARRACK)
			barrack_c.new_rally(mouse_global_position)
	
	select_type = C.SELECT.NONE
