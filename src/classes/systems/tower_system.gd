extends System
class_name TowerSystem
## 防御塔系统。
##
## TowerSystem 负责处理拥有 [TowerComponent] 防御塔组件的实体，包括升级、建造等。


func _on_insert(e: Entity) -> bool:
	var tower_c: TowerComponent = e.get_node_or_null(C.CN_TOWER)
	if not tower_c:
		return true
		
	for child: Node in tower_c.get_children():
		var entity_list: Array = []
		
		if child is EntityGroup2D:
			entity_list = child.get_children()
		else:
			entity_list = [child]
			
		for sub_e: Entity in entity_list:
			sub_e.source_id = e.id
			EntityMgr.setup_entity(sub_e)
			sub_e.insert_entity()
		
	if not tower_c.tower_holder:
		tower_c.tower_holder = GameMgr.defaul_tower_holder
		
	if tower_c.tower_type == TowerComponent.TowerType.TOWER_HOLDER:
		tower_c.total_price = 0
		
	return true
	
	
func _on_update(_delta: float) -> void:
	for e: Entity in EntityMgr.get_entities_group(C.CN_TOWER):
		var tower_c: TowerComponent = e.get_node_or_null(C.CN_TOWER)
		
		# 处理防御塔升级
		if tower_c.upgrade_to:
			var new_tower: Entity = EntityMgr.create_entity(tower_c.upgrade_to)
			var new_tower_c: TowerComponent = new_tower.get_node_or_null(C.CN_TOWER)
			
			var price: float = 0.0
			if new_tower_c.tower_type == TowerComponent.TowerType.TOWER_BUILD:
				var build_target: Entity = EntityMgr.get_entity_data(new_tower.build_target)
				var build_target_tower_c: TowerComponent = build_target.get_node_or_null(C.CN_TOWER)
				price = build_target_tower_c.price
			else:
				price = new_tower_c.price
				
			new_tower.global_position = e.global_position
			new_tower_c.total_price = (
				tower_c.total_price + price
			)
			new_tower_c.tower_holder = tower_c.tower_holder
			new_tower_c.is_builded = tower_c.tower_type == TowerComponent.TowerType.TOWER_BUILD
			
			var default_rally_center_local_pos: Vector2 = tower_c.default_rally_center_local_pos
			new_tower_c.default_rally_center_local_pos = default_rally_center_local_pos
			
			var new_barrack_c: BarrackComponent = new_tower.get_node_or_null(C.CN_BARRACK)
			if new_barrack_c:
				var barrack_c: BarrackComponent = e.get_node_or_null(C.CN_BARRACK)
				if barrack_c:
					new_barrack_c.rally_center_position = barrack_c.rally_center_position
					new_barrack_c.last_soldier_group = barrack_c.soldier_group
				else:
					new_barrack_c.rally_center_position = tower_c.to_global(default_rally_center_local_pos)
			
			new_tower.insert_entity()
			e.remove_entity()

			if not new_tower_c.is_builded:
				GameMgr.cash -= price
		if tower_c.is_sell:
			AudioMgr.play_sfx(tower_c.sell_sfx)
			
			var tower_holder: Entity = EntityMgr.create_entity(tower_c.tower_holder)
			tower_holder.global_position = e.global_position
			var holder_tower_c: TowerComponent = tower_holder.get_node_or_null(C.CN_TOWER)
			holder_tower_c.default_rally_center_local_pos = tower_c.default_rally_center_local_pos
			
			tower_holder.insert_entity()
			e.remove_entity()
			
			GameMgr.cash += (
				tower_c.sell_ratio * tower_c.total_price
			)
