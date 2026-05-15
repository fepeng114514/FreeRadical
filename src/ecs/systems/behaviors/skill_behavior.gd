extends Behavior
class_name SkillBehavior
## 技能行为系统
##
## 处理拥有 [SkillComponent] 技能组件的实体的技能释放


func _on_update(e: Entity) -> bool:
	var skill_c: SkillComponent = e.get_node_or_null(C.CN_SKILL)
	if not skill_c:
		return false
		
	for i: int in skill_c.get_child_count():
		var skill: SkillBase = skill_c.get_child(i)
		
		if not TimeMgr.is_ready_time(skill.ts, skill.cooldown):
			continue
			
		var tick_ts: float = TimeMgr.tick_ts
		skill.ts = tick_ts
		
		if skill.group_cooldown_enable:
			var parent: Node = e.get_parent()
			if parent is EntityGroup2D:
				for member: Entity in parent.get_children():
					if member == e:
						continue
					
					var member_skill_c: SkillComponent = member.get_node_or_null(C.CN_SKILL)
					if not member_skill_c:
						continue
						
					var member_s: SkillBase = member_skill_c.get_child(i)
					member_s.ts = tick_ts - skill.group_cooldown_offset
		
		skill._do_skill(e)
			
		return true
			
	return false
