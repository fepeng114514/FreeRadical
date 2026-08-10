extends SelectMenuButton
class_name SelectMenuButtonRally


func _on_pressed() -> void:
	SelectMgr.select_mode = SelectMgr.SelectMode.BARRACK_RALLY
	select_menu._hide()
		
