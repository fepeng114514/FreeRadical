extends System
class_name SellSystem
## 卖售系统。
##
## [SellSystem] 负责处理拥有 [SellComponent] 的实体的出售。


func _on_update(_delta: float) -> void:
	for entity: Entity in EntityManager.get_component_entity_group(Enums.ComponentFlag.SELL):
		var sell_c: SellComponent = entity.get_node_or_null(Constants.SELL_COMPONENT_NODE_PATH)
		if not sell_c.is_selling:
			continue

		var sell_c_config: SellComponentNodeConfig = sell_c.config
		if sell_c_config.disabled:
			continue

		AudioManager.play_sfx(sell_c_config.sell_sfx)
		
		var new_entity: Entity = null
		match sell_c_config.created_entity_type:
			SellComponent.CreatedEntityType.TOWER_HOLDER:
				var tower_record: TowerRecord = entity.get_node_or_null(Constants.TOWER_RECORD_NODE_PATH)
				new_entity = EntityManager.create_entity(tower_record.tower_holder)
		
		new_entity.global_position = entity.global_position
		
		var record_c: RecordComponent = entity.get_node_or_null(Constants.RECORD_COMPONENT_NODE_PATH)
		var new_record_c: RecordComponent = new_entity.get_node_or_null(Constants.RECORD_COMPONENT_NODE_PATH)
		if record_c and new_record_c:
			record_c.transmit_record(new_record_c)

		var price_record: PriceRecord = entity.get_node_or_null(Constants.PRICE_RECORD_NODE_PATH)
		GameManager.cash += sell_c_config.sell_ratio * price_record.total_price
		price_record.total_price = 0
		
		EntityManager.queue_remove_entity(entity)
		EntityManager.queue_insert_entity(new_entity)