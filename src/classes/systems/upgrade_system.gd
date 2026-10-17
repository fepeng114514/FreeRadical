extends System
class_name UpgradeSystem
## 升级系统。
##
## [UpgradeSystem] 负责处理拥有 [UpgradeComponent] 的实体的升级。


func _on_update(_delta: float) -> void:
	for entity: Entity in EntityManager.get_component_entity_group(Enums.ComponentFlag.UPGRADE):
		var upgrade_c: UpgradeComponent = entity.get_node_or_null(Constants.UPGRADE_COMPONENT_NODE_PATH)
		var current_upgrading_index: int = upgrade_c.current_upgrading_index
		if not Utils.is_valid_number(current_upgrading_index):
			continue
			
		var upgrade_item: UpgradeItem = upgrade_c.config.upgrade_items.upgrade_items[current_upgrading_index]
		
		var new_entity: Entity = EntityManager.create_entity(upgrade_item.upgrade_to)
		new_entity.global_position = entity.global_position

		var record_c: RecordComponent = entity.get_node_or_null(Constants.RECORD_COMPONENT_NODE_PATH)
		var new_record_c: RecordComponent = new_entity.get_node_or_null(Constants.RECORD_COMPONENT_NODE_PATH)
		if record_c and new_record_c:
			record_c.transmit_record(new_record_c)
		
		var new_price_record: PriceRecord = new_entity.get_node_or_null(Constants.PRICE_RECORD_NODE_PATH)
		if new_price_record:
			new_price_record.total_price += upgrade_item.price
		
		GameManager.cash -= upgrade_item.price
		EntityManager.queue_remove_entity(entity)
		EntityManager.queue_insert_entity(new_entity)
