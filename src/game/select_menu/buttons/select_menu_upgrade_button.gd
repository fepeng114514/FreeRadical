extends SelectMenuButton
class_name SelectMenuUpgradeButton


@export_group("Ref")
## 价格标签引用。
@export var price_tag: TextureRect = null

## 升级项索引。
var upgrade_item_index: int = 0

@onready var price_tag_label: Label = price_tag.get_node("Label")


func _update() -> void:
	var upgrade_c: UpgradeComponent = selected_entity.get_node_or_null(Constants.UPGRADE_COMPONENT_NODE_PATH)
	var upgrade_item: UpgradeItem = upgrade_c.config.upgrade_items.upgrade_items[upgrade_item_index]
	
	var price: float = upgrade_item.price
	if price > GameManager.cash:
		_disable()
	else:
		_enable()
			
	price_tag_label.text = "%d" % price


func _on_pressed() -> void:
	super()

	var upgrade_c: UpgradeComponent = selected_entity.get_node_or_null(Constants.UPGRADE_COMPONENT_NODE_PATH)
	upgrade_c.current_upgrading_index = upgrade_item_index
