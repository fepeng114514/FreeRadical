extends System
class_name TowerSystem
## 防御塔系统。
##
## TowerSystem 负责处理拥有 [TowerComponent] 防御塔组件的实体，包括升级、建造等。


func _on_insert(tower: Entity) -> bool:
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

		EntityManager.setup_entity(child)
		EntityManager.queue_insert_entity(child)
		
	if not tower_c.tower_holder:
		var tower_record: PriceRecord = tower_c.get_node_or_null(Constants.CN_PRICE_RECORD)
		if tower_record:
			tower_c.tower_holder = tower_record.tower_holder
		else:
			tower_c.tower_holder = GameManager.default_tower_holder
		
	return true


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
			skill.time_stamp = used_skill.time_stamp - tower_c.shooter_alternation_offset