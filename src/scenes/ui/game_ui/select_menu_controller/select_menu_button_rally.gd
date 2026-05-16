extends SelectMenuButton
class_name SelectMenuButtonRally


func _on_pressed() -> void:
	SelectMgr.select_mode = SelectMgr.SelectMode.BARRACK_RALLY
	select_menu.hide_select_menu.emit()
		
