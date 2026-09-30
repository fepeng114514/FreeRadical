extends System
class_name TowerSystem
## 防御塔系统。
##
## TowerSystem 负责处理拥有 [TowerComponent] 防御塔组件的实体，包括升级、建造等。


func _on_insert(tower: Entity) -> bool:
	var tower_c: TowerComponent = tower.get_node_or_null(Constants.CN_TOWER)
	if not tower_c:
		return true
		
	for shooter: Entity in tower_c.get_children():
		shooter.source_id = tower.id
		shooter.source_type = Entity.SourceType.TOWER_SHOOTER

		if tower_c.shooter_alternation_enabled:
			var skill_c: SkillComponent = shooter.get_node_or_null(Constants.CN_SKILL)
			if skill_c:
				skill_c.start_skill_cooldown.connect(_on_start_skill_cooldown.bind(tower_c, shooter))

		EntityManager.setup_entity(shooter)
		EntityManager.queue_insert_entity(shooter)
		
	var tower_record: TowerRecord = tower.get_node_or_null(Constants.CN_TOWER_RECORD)
	if not tower_record.tower_holder:
		tower_record.tower_holder = GameManager.default_tower_holder
		
	return true


func _on_start_skill_cooldown(used_skill: Skill, tower_c: TowerComponent, used_shooter: Entity) -> void:
	if not tower_c.shooter_alternation_enabled:
		return
		
	var alternation_entities: Array[NodePath] = tower_c.shooter_alternation_entities
	var alternation_entities_size: int = alternation_entities.size()
	if alternation_entities_size <= 1:
		return

	var current_alternation_index: int = tower_c.current_shooter_alternation_index
	if not Utils.is_valid_number(current_alternation_index):
		current_alternation_index = alternation_entities.find(tower_c.get_path_to(used_shooter))
	
	current_alternation_index = (current_alternation_index + 1) % alternation_entities_size
	tower_c.current_shooter_alternation_index = current_alternation_index

	for shooter_path: NodePath in alternation_entities:
		var shooter: Entity = tower_c.get_node(shooter_path)
		if shooter == used_shooter:
			continue

		var skill_c: SkillComponent = shooter.get_node_or_null(Constants.CN_SKILL)
		for skill: Skill in skill_c.get_children():
			skill.time_stamp = used_skill.time_stamp - tower_c.shooter_alternation_offset