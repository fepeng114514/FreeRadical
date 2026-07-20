extends Behavior
class_name SkillBehavior
## 技能行为。
##
## SkillBehavior 负责处理拥有 [SkillComponent] 技能组件的实体的技能释放。


func _on_update(e: Entity) -> bool:
	var skill_c: SkillComponent = e.get_node_or_null(C.CN_SKILL)
	if not skill_c:
		return false
		
	for i: int in skill_c.get_child_count():
		var skill: Skill = skill_c.get_child(i)
		if not skill.can_do(e):
			continue
			
		skill._do_skill(e)

		return true
			
	return false
