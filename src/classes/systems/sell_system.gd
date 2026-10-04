extends System
class_name SellSystem
## 卖售系统。
##
## SellSystem 负责处理拥有 [SellComponent] 出售组件的实体的出售。


func _on_update(_delta: float) -> void:
	for entity: Entity in EntityManager.get_component_entity_group(Constants.SELL_COMPONENT_NAME):
		var sell_c: SellComponent = entity.get_node_or_null(Constants.SELL_COMPONENT_NODE_PATH)
		if not sell_c.is_selling or sell_c.config.disabled:
			continue

		AudioManager.play_sfx(sell_c.config.sell_sfx)
		_process_tower_component(entity)
		EntityManager.queue_remove_entity(entity)
		
		var price_record: PriceRecord = entity.get_node_or_null(Constants.PRICE_RECORD_NODE_PATH)
		if not price_record:
			continue

		GameManager.cash += sell_c.config.sell_ratio * price_record.total_price
	

func _process_tower_component(entity: Entity) -> void:
	var tower_c: TowerComponent = entity.get_node_or_null(Constants.TOWER_COMPONENT_NODE_PATH)
	if not tower_c:
		return

	var tower_record: TowerRecord = entity.get_node_or_null(Constants.TOWER_RECORD_NODE_PATH)
	var tower_holder: Entity = EntityManager.create_entity(tower_record.tower_holder)
	tower_holder.set_global_position_with_components(entity.global_position)
	
	EntityManager.queue_insert_entity(tower_holder)
