extends SelectMenuButton
class_name SelectMenuButtonRally


func _on_pressed() -> void:
	SelectManager.select_mode = SelectManager.SelectMode.BARRACK_RALLY
	select_menu._hide()
		
