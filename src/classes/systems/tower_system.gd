extends System
class_name TowerSystem
## 防御塔系统。
##
## TowerSystem 负责处理拥有 [TowerComponent] 防御塔组件的实体，包括升级、建造等。


func _on_insert(tower: Entity) -> bool:
	var tower_c: TowerComponent = tower.get_node_or_null(Constants.TOWER_COMPONENT_NODE_PATH)
	if not tower_c:
		return true
		
	for shooter: Entity in tower_c.get_children():
		shooter.source_id = tower.id
		shooter.source_type = Entity.SourceType.TOWER_SHOOTER

		if tower_c.config.shooter_alternation_enabled:
			var skill_c: SkillComponent = shooter.get_node_or_null(Constants.SKILL_COMPONENT_NODE_PATH)
			if skill_c:
				skill_c.start_skill_cooldown.connect(_on_start_skill_cooldown.bind(tower_c, shooter))

		EntityManager.setup_entity(shooter)
		EntityManager.queue_insert_entity(shooter)
		
	return true


func _on_start_skill_cooldown(used_skill: Skill, tower_c: TowerComponent, used_shooter: Entity) -> void:
	var tower_c_config: TowerComponentNodeConfig = tower_c.config
	if not tower_c_config.shooter_alternation_enabled:
		return
		
	var alternation_entity_indexes: Array[int] = tower_c_config.shooter_alternation_entity_indexes
	var alternation_entity_indexes_size: int = alternation_entity_indexes.size()
	if alternation_entity_indexes_size <= 1:
		return

	var current_alternation_index: int = tower_c.current_shooter_alternation_index
	if not Utils.is_valid_number(current_alternation_index):
		current_alternation_index = alternation_entity_indexes.find(used_shooter.get_index())
	
	current_alternation_index = (current_alternation_index + 1) % alternation_entity_indexes_size
	tower_c.current_shooter_alternation_index = current_alternation_index

	for shooter_index: int in alternation_entity_indexes:
		var shooter: Entity = tower_c.get_child(shooter_index)
		if shooter == used_shooter:
			continue
		
		var skill_c: SkillComponent = shooter.get_node_or_null(Constants.SKILL_COMPONENT_NODE_PATH)
		for skill: Skill in skill_c.get_children():
			skill.timestamp = used_skill.timestamp - tower_c_config.shooter_alternation_offset
