extends ECSSystem
class_name TowerSystem
## 防御塔系统。
##
## TowerSystem 负责处理拥有 [TowerComponent] 防御塔组件的实体，包括升级、建造等。


func _on_insert(tower: ECSEntity) -> bool:
	tower = tower as Entity
	var tower_c: TowerComponent = tower.get_node_or_null(Constants.CN_TOWER)
	if not tower_c:
		return true
		
	for child: Entity in tower_c.get_children():
		child.source_id = tower.id
		child.source_type = Entity.SourceType.TOWER_SHOOTER

		if tower_c.shooter_switch_enabled:
			var skill_c: SkillComponent = child.get_node_or_null(Constants.CN_SKILL)
			if skill_c:
				skill_c.start_skill_cooldown.connect(_on_start_skill_cooldown.bind(tower_c, child))

		ECSEntityManager.setup_entity(child)
		ECSEntityManager.queue_insert_entity(child)
		
	if not tower_c.tower_holder:
		tower_c.tower_holder = GameManager.defaul_tower_holder
		
	if tower_c.tower_type == TowerComponent.TowerType.TOWER_HOLDER:
		tower_c.total_price = 0
		
	return true
	
	
func _on_update(_delta: float) -> void:
	for tower: Entity in ECSEntityManager.get_component_entity_group(Constants.CN_TOWER):
		var tower_c: TowerComponent = tower.get_node_or_null(Constants.CN_TOWER)
		
		# 处理防御塔升级
		if tower_c.upgrade_to:
			var new_tower: Entity = ECSEntityManager.create_entity(tower_c.upgrade_to)
			var new_tower_c: TowerComponent = new_tower.get_node_or_null(Constants.CN_TOWER)
			
			var price: float = 0.0
			if new_tower_c.tower_type == TowerComponent.TowerType.TOWER_BUILD:
				var build_target: Entity = ECSEntityManager.get_entity_data(new_tower.build_target)
				var build_target_tower_c: TowerComponent = build_target.get_node_or_null(Constants.CN_TOWER)
				price = build_target_tower_c.price
			else:
				price = new_tower_c.price
				
			new_tower.global_position = tower.global_position
			new_tower_c.total_price = (
				tower_c.total_price + price
			)
			new_tower_c.tower_holder = tower_c.tower_holder
			new_tower_c.is_builded = tower_c.tower_type == TowerComponent.TowerType.TOWER_BUILD
			
			var default_rally_center_position: Vector2 = tower_c.default_rally_center_position
			new_tower_c.default_rally_center_position = default_rally_center_position
			
			var new_barrack_c: BarrackComponent = new_tower.get_node_or_null(Constants.CN_BARRACK)
			if new_barrack_c:
				var barrack_c: BarrackComponent = tower.get_node_or_null(Constants.CN_BARRACK)
				if barrack_c:
					new_barrack_c.rally_center_global_position = barrack_c.rally_center_global_position
					new_barrack_c.last_soldier_list = barrack_c.soldier_list
				else:
					new_barrack_c.rally_center_global_position = tower_c.to_global(default_rally_center_position)
			
			ECSEntityManager.queue_insert_entity(new_tower)
			ECSEntityManager.queue_remove_entity(tower)

			if not new_tower_c.is_builded:
				GameManager.cash -= price
		if tower_c.is_sell:
			AudioManager.play_sfx(tower_c.sell_sfx)
			
			var tower_holder: Entity = ECSEntityManager.create_entity(tower_c.tower_holder)
			tower_holder.global_position = tower.global_position
			tower_holder.default_rally_center_position = tower_c.default_rally_center_position
			
			ECSEntityManager.queue_insert_entity(tower_holder)
			ECSEntityManager.queue_remove_entity(tower)
			
			GameManager.cash += (
				tower_c.sell_ratio * tower_c.total_price
			)


func _on_start_skill_cooldown(used_skill: Skill, tower_c: TowerComponent, used_shooter: Entity) -> void:
	if not tower_c.shooter_alternation_enabled:
		return
		
	var shooter_alternation_indexes: Array[int] = tower_c.shooter_alternation_indexes
	var shooter_alternation_indexes_size: int = shooter_alternation_indexes.size()
	if shooter_alternation_indexes_size <= 1:
		return

	var shooter_alternation_index: int = tower_c.shooter_alternation_index
	if not Utils.is_valid_number(shooter_alternation_index):
		shooter_alternation_index = shooter_alternation_indexes.find(used_shooter.get_index())
	
	shooter_alternation_index = (shooter_alternation_index + 1) % shooter_alternation_indexes_size
	tower_c.shooter_alternation_index = shooter_alternation_index

	for shooter_index: int in shooter_alternation_indexes:
		var shooter: Entity = tower_c.get_child(shooter_index)
		if shooter == used_shooter:
			continue

		var skill_c: SkillComponent = shooter.get_node_or_null(Constants.CN_SKILL)
		for skill: Skill in skill_c.get_children():
			skill.ts = used_skill.ts - tower_c.shooter_alternation_offset