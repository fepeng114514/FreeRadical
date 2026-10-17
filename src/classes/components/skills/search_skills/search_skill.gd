@abstract
extends Skill
class_name SearchSkill
## 搜索技能基类。
##
## [SearchSkill] 是所有搜索技能节点的基类。搜索技能会搜索目标实体。


## 获取搜索中心。
func get_search_global_position(entity: Entity) -> Vector2:
	var search_global_position: Vector2 = entity.global_position
	if entity.source_type == Entity.SourceType.TOWER_SHOOTER:
		search_global_position.y -= entity.position.y

	return search_global_position


func search_target(config: SearchSkillNodeConfig, entity: Entity) -> Entity:
	var filter: Callable = func(target: Entity) -> bool:
		var interact_policy_c: InteractPolicyComponent = target.get_node_or_null(Constants.INTERACT_POLICY_COMPONENT_NODE_PATH)
		if not interact_policy_c:
			return true

		if interact_policy_c.config.skill_type_bans & config.skill_types:
			return false

		return true
		
	return config.searcher.search_target(get_search_global_position(entity), entity, filter)
