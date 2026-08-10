extends Behavior
class_name SkillBehavior
## 技能行为。
##
## SkillBehavior 负责处理拥有 [SkillComponent] 技能组件的实体的技能释放。


func _on_insert(e: Entity) -> bool:
	var skill_c: SkillComponent = e.get_node_or_null(C.CN_SKILL)
	if not skill_c:
		return true

	for skill: Skill in skill_c.get_children():
		skill.start_skill_cooldown.connect(_on_skill_cooldown_start.bind(skill_c, skill))

	return true


func _on_update(e: Entity) -> bool:
	var skill_c: SkillComponent = e.get_node_or_null(C.CN_SKILL)
	if not skill_c:
		return false
		
	for skill: Skill in skill_c.get_children():
		if not skill.can_use(e):
			continue

		skill.use_skill(e)
		skill_c.skill_used.emit(skill)

		return true
			
	return false


func _on_skill_cooldown_start(skill_c: SkillComponent, skill: Skill) -> void:
	skill_c.start_skill_cooldown.emit(skill)
