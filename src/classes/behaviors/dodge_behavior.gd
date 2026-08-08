extends Behavior
class_name DodgeBehavior
## 闪避行为。
##
## DodgeBehavior 负责处理拥有 [DodgeComponent] 闪避组件的实体闪避行为。


func _on_update(e: Entity) -> bool:
	var dodge_c: DodgeComponent = e.get_node_or_null(C.CN_DODGE)
	if not dodge_c:
		return false

	if not e.state & Entity.State.DODGE:
		return false

	e.state &= ~Entity.State.DODGE

	var skill: Skill = dodge_c.get_child(dodge_c.skill_idx)
	if not skill:
		return false

	var target: Entity = EntityMgr.get_entity_by_id(dodge_c.target_id)
	if not target:
		return false

	skill._use_skill(e, target)
	return true
