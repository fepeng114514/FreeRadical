extends Behavior
class_name SkillBehavior


func _on_update(e: Entity) -> bool:
	var skill_c: SkillComponent = e.get_node_or_null(C.CN_HEALTH)
	if not skill_c:
		return false
		
	return false
