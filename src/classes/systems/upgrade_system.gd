extends ECSSystem
class_name UpgradeSystem
## 升级系统。
##
## UpgradeSystem 负责处理拥有 [UpgradeComponent] 升级组件的实体的升级。


func _on_update(_delta: float) -> void:
	for entity: Entity in ECSEntityManager.get_component_entity_group(Constants.CN_UPGRADE):
		var upgrade_c: UpgradeComponent = entity.get_node_or_null(Constants.CN_UPGRADE)
		if not upgrade_c.upgrade_to:
			continue

		var new_entity: Entity = ECSEntityManager.create_entity(upgrade_c.upgrade_to)
		new_entity.global_position = entity.global_position
		
		_process_price_component(entity, upgrade_c, new_entity)
		_process_tower_component(entity, new_entity)
		
		ECSEntityManager.queue_insert_entity(new_entity)
		ECSEntityManager.queue_remove_entity(entity)
		GameManager.cash -= upgrade_c.price


func _process_price_component(entity: Entity, upgrade_c: UpgradeComponent, new_entity: Entity) -> void:
	var price_record: PriceRecord = entity.get_node_or_null(Constants.CN_PRICE_RECORD)
	if not price_record:
		return

	var new_price_record: PriceRecord = new_entity.get_node_or_null(Constants.CN_PRICE_RECORD)
	if not new_price_record:
		return
			
	new_price_record.price = price_record.price + upgrade_c.price


func _process_tower_component(entity: Entity, new_entity: Entity) -> void:
	var tower_c: TowerComponent = entity.get_node_or_null(Constants.CN_TOWER)
	if not tower_c:
		return

	var default_rally_center_position: Vector2 = tower_c.default_rally_center_position

	var new_barrack_c: BarrackComponent = new_entity.get_node_or_null(Constants.CN_BARRACK)
	if new_barrack_c:
		var barrack_c: BarrackComponent = entity.get_node_or_null(Constants.CN_BARRACK)
		if barrack_c:
			new_barrack_c.rally_center_global_position = barrack_c.rally_center_global_position
			new_barrack_c.last_soldier_list = barrack_c.soldier_list
		else:
			new_barrack_c.rally_center_global_position = tower_c.to_global(default_rally_center_position)
		