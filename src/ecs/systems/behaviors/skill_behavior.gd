extends Behavior
class_name SkillBehavior


func _on_update(e: Entity) -> bool:
	var skill_c: SkillComponent = e.get_node_or_null(C.CN_SKILL)
	if not skill_c:
		return false
		
	for i: int in skill_c.get_child_count():
		var s: SkillBase = skill_c.get_child(i)
		
		if not TimeMgr.is_ready_time(s.ts, s.cooldown):
			continue
			
		if s.search_enable:
			var targets: Array[Entity] = EntityMgr.search_targets(
				s.search_mode, 
				e.global_position, 
				s.max_range, 
				s.min_range, 
				s.flags, 
				s.bans
			)
			if not targets:
				continue
					
		var tick_ts: float = TimeMgr.tick_ts
		s.ts = tick_ts
		
		if s.group_cooldown_enable:
			var parent: Node = e.get_parent()
			if parent is EntityGroup2D:
				for member: Entity in parent.get_children():
					if member == e:
						continue
					
					var member_skill_c: SkillComponent = e.get_node_or_null(C.CN_SKILL)
					if not member_skill_c:
						continue
						
					var member_s: SkillBase = member_skill_c.get_child(i)
					member_s.ts = tick_ts - s.group_cooldown_offset
		
		# if a is RangedAttack:
		# 	_do_single_attack(a, e, target)
			
		return true
		
	return false
