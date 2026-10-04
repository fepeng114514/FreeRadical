extends SelectMenuButton
class_name SelectMenuRallyButton


func _on_pressed() -> void:
	super()
		
	SelectManager.select_mode = SelectManager.SelectMode.BARRACK_RALLY
	select_menu._hide()
		
