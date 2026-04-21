extends Behavior
class_name BarrackBehavior
## 兵营行为系统
##
## 处理拥有 [BarrackComponent] 兵营组件的实体生成士兵
	

func _on_update(e: Entity) -> bool:
	var barrack_c: BarrackComponent = e.get_node_or_null(C.CN_BARRACK)
	if not barrack_c:
		return false
		
	var soldier_group: EntityGroup = barrack_c.soldier_group
		
	if e.is_first_update:
		e.play_animation_by_look(barrack_c.animation)
		AudioMgr.play_sfx(barrack_c.sfx)
		if barrack_c.delay:
			await e.y_wait(barrack_c.delay)
			
		var max_soldiers: int = barrack_c.max_soldiers
			
		for i: int in max_soldiers:
			var soldier: Entity = respawn_soldier(e, barrack_c, soldier_group)
			var s_rally_c: RallyComponent = soldier.get_node_or_null(C.CN_RALLY)
			s_rally_c.rally_formation_position(max_soldiers, i)
	
	var soldier_count: int = soldier_group.get_child_count()
	
	# 根据重生时间生成士兵
	if TimeMgr.is_ready_time(barrack_c.ts, barrack_c.respawn_time):
		respawn_soldier(e, barrack_c, soldier_group)
		barrack_c.ts = TimeMgr.tick_ts
	
	# 士兵数发生变化重新整队
	if barrack_c.last_soldier_count != soldier_count:
		for i: int in soldier_count:
			var soldier: Entity = soldier_group.get_child(i)
			var s_rally_c: RallyComponent = soldier.get_node_or_null(C.CN_RALLY)
			s_rally_c.rally_formation_position(soldier_count, i)
	
	barrack_c.last_soldier_count = soldier_count
	return false


func respawn_soldier(
		barrack: Entity, barrack_c: BarrackComponent, soldier_group: EntityGroup
	) -> Variant:
	if soldier_group.get_child_count() >= barrack_c.max_soldiers:
		return null
		
	var soldier: Entity = EntityMgr.create_entity(barrack_c.soldier)
	soldier.global_position = barrack.global_position
	
	var rally_c: RallyComponent = soldier.get_node_or_null(C.CN_RALLY)
	rally_c.new_rally(barrack_c.rally_pos, barrack_c.rally_radius)
		
	if not barrack._on_barrack_respawn(soldier, barrack_c):
		return soldier
	
	soldier_group.add_child(soldier)
	soldier.insert_entity()
	
	return soldier
