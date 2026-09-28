extends System
class_name SellSystem
## 卖售系统。
##
## SellSystem 负责处理拥有 [SellComponent] 出售组件的实体的出售。


func _on_update(_delta: float) -> void:
	for entity: Entity in EntityManager.get_component_entity_group(Constants.CN_SELL):
		var sell_c: SellComponent = entity.get_node_or_null(Constants.CN_SELL)
		if not sell_c.is_sold or not sell_c.sell_enabled:
			continue

		AudioManager.play_sfx(sell_c.sell_sfx)
		_process_tower_component(sell_c.tower_component)
		EntityManager.queue_remove_entity(entity)
		
		var price_record: PriceRecord = entity.get_node_or_null(Constants.CN_PRICE_RECORD)
		if not price_record:
			continue

		GameManager.cash += sell_c.sell_ratio * price_record.price
	

func _process_tower_component(entity: Entity) -> void:
	var tower_c: TowerComponent = entity.get_node_or_null(Constants.CN_TOWER)
	if not tower_c:
		return

	var tower_holder: Entity = EntityManager.create_entity(tower_c.tower_holder)
	tower_holder.set_global_position_with_components(entity.global_position)
	
	EntityManager.queue_insert_entity(tower_holder)