extends System
class_name TowerSystem
## 防御塔系统。
##
## TowerSystem 负责处理拥有 [TowerComponent] 防御塔组件的实体，包括升级、建造等。


func _on_insert(e: Entity) -> bool:
	var tower_c: TowerComponent = e.get_node_or_null(C.CN_TOWER)
	if not tower_c:
		return true
		
	for child: Entity in tower_c.get_children():
		child.source_id = e.id
		child.source_type = Entity.SourceType.TOWER_SHOOTER

		if tower_c.shooter_switch_enable:
			var skill_c: SkillComponent = child.get_node_or_null(C.CN_SKILL)
			if skill_c:
				skill_c.start_skill_cooldown.connect(_on_start_skill_cooldown.bind(tower_c, child))

		EntityMgr.setup_entity(child)
		child.insert_entity()
		
	if not tower_c.tower_holder:
		tower_c.tower_holder = GameMgr.defaul_tower_holder
		
	if tower_c.tower_type == TowerComponent.TowerType.TOWER_HOLDER:
		tower_c.total_price = 0
		
	return true
	
	
func _on_update(_delta: float) -> void:
	for e: Entity in EntityMgr.get_component_group(C.CN_TOWER):
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
					new_barrack_c.last_soldier_list = barrack_c.soldier_list
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
			tower_holder.default_rally_center_local_pos = tower_c.default_rally_center_local_pos
			
			tower_holder.insert_entity()
			e.remove_entity()
			
			GameMgr.cash += (
				tower_c.sell_ratio * tower_c.total_price
			)


func _on_start_skill_cooldown(used_skill: Skill, tower_c: TowerComponent, used_shooter: Entity) -> void:
	if not tower_c.shooter_switch_enable:
		return

	var shooter_switch_list: Array[Entity] = tower_c.shooter_switch_list
	var shooter_switch_list_size: int = shooter_switch_list.size()
	if shooter_switch_list_size <= 1:
		return

	var current_shooter_switch_idx: int = tower_c.current_shooter_switch_idx
	if not U.is_valid_number(current_shooter_switch_idx):
		current_shooter_switch_idx = shooter_switch_list.find(used_shooter)
	
	tower_c.current_shooter_switch_idx = (current_shooter_switch_idx + 1) % shooter_switch_list_size

	for i: int in shooter_switch_list_size:
		var shooter: Entity = shooter_switch_list[i]
		if shooter == used_shooter:
			continue

		var skill_c: SkillComponent = shooter.get_node_or_null(C.CN_SKILL)
		for skill: Skill in skill_c.get_children():
			skill.ts = used_skill.ts

			if tower_c.current_shooter_switch_idx == i:
				skill.ts -= tower_c.shooter_switch_offset
				continue
