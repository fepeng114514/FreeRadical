extends Behavior
class_name DodgeBehavior
## 闪避行为。
##
## DodgeBehavior 负责处理拥有 [DodgeComponent] 闪避组件的实体闪避行为。


func _on_update(entity: Entity) -> bool:
	var dodge_c: DodgeComponent = entity.get_node_or_null(Constants.DODGE_COMPONENT_NODE_PATH)
	if not dodge_c:
		return false

	if not entity.state & Entity.State.DODGE:
		return false

	entity.state &= ~Entity.State.DODGE

	var skill: Skill = dodge_c.get_child(dodge_c.skill_index)
	if not skill:
		return false

	var target: Entity = EntityManager.get_entity_by_id(dodge_c.target_id)
	if not target:
		return false

	skill._use_skill(entity, target)
	return true
