extends SelectMenuButton
class_name SelectMenuSellButton

	
func _on_pressed() -> void:
	super()

	var sell_c: SellComponent = selected_entity.get_node_or_null(Constants.SELL_COMPONENT_NODE_PATH)
	sell_c.is_selling = true
