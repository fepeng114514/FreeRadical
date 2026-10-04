extends System
class_name UpgradeSystem
## 升级系统。
##
## UpgradeSystem 负责处理拥有 [UpgradeComponent] 升级组件的实体的升级。


func _on_update(_delta: float) -> void:
	for entity: Entity in EntityManager.get_component_entity_group(Constants.UPGRADE_COMPONENT_NAME):
		var upgrade_c: UpgradeComponent = entity.get_node_or_null(Constants.UPGRADE_COMPONENT_NODE_PATH)
		var current_upgrading_index: int = upgrade_c.current_upgrading_index
		if not Utils.is_valid_number(current_upgrading_index):
			continue
			
		var upgrade_item: UpgradeItem = upgrade_c.config.upgrade_items.upgrade_items[current_upgrading_index]
		
		var new_entity: Entity = EntityManager.create_entity(upgrade_item.upgrade_to)
		new_entity.global_position = entity.global_position
		
		_process_price_component(entity, upgrade_item, new_entity)
		_process_tower_component(entity, new_entity)
		
		EntityManager.queue_insert_entity(new_entity)
		EntityManager.queue_remove_entity(entity)
		GameManager.cash -= upgrade_item.price


func _process_price_component(entity: Entity, upgrade_item: UpgradeItem, new_entity: Entity) -> void:
	var price_record: PriceRecord = entity.get_node_or_null(Constants.PRICE_RECORD_NODE_PATH)
	if not price_record:
		return

	var new_price_record: PriceRecord = new_entity.get_node_or_null(Constants.PRICE_RECORD_NODE_PATH)
	if not new_price_record:
		return
			
	new_price_record.total_price += upgrade_item.price


func _process_tower_component(entity: Entity, new_entity: Entity) -> void:
	var tower_c: TowerComponent = entity.get_node_or_null(Constants.TOWER_COMPONENT_NODE_PATH)
	if not tower_c:
		return

	var new_barrack_c: BarrackComponent = new_entity.get_node_or_null(Constants.BARRACK_COMPONENT_NODE_PATH)
	if new_barrack_c:
		var barrack_c: BarrackComponent = entity.get_node_or_null(Constants.BARRACK_COMPONENT_NODE_PATH)
		if barrack_c:
			new_barrack_c.config.rally_center_global_position = barrack_c.config.rally_center_global_position
			new_barrack_c.last_soldier_list = barrack_c.soldier_list
