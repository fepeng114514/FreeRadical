extends System
class_name AuraSystem
## 光环系统。
##
## AuraSystem 负责处理拥有 [AuraComponent] 光环组件的实体。


func _on_insert(e: Entity) -> bool:
	var aura_c: AuraComponent = e.get_node_or_null(C.CN_AURA)
	if not aura_c:
		return true
		
	var target: Entity = EntityMgr.get_entity_by_id(e.target_id)
	if not target:
		return false

	var interact_p: InteractPolicy = e.interact_policy
	if not InteractPolicy.is_allowed_target(e, target, interact_p, target.interact_policy):
		return false
		
	aura_c.ts = TimeMgr.tick_ts
	e.global_position = target.global_position

	var same_aura_list: Array[Entity] = []

	for other_aura: Entity in target.get_has_aura_list():
		if other_aura == e:
			continue

		var other_interact_p: InteractPolicy = other_aura.interact_policy
		
		# 检查是否被其他光环禁止
		if (
			other_interact_p.is_banned(interact_p) 
			or other_interact_p.is_aura_type_banned(interact_p)
			or not other_interact_p.is_scene_allowed(e.scene_name)
		):
			return false
		
		# 检查是否被当前光环禁止
		if (
			interact_p.is_banned(other_interact_p) 
			or interact_p.is_aura_type_banned(other_interact_p)
			or not interact_p.is_scene_allowed(target.scene_name)
		):
			if aura_c.remove_banned:
				other_aura.remove_entity()
				continue
			
			return false
		
		if other_aura.scene_name == e.scene_name:
			same_aura_list.append(other_aura)	
			
	if same_aura_list and aura_c.same_process:
		if not aura_c.same_process.process(e, same_aura_list):
			return false

	target.has_auras_id_list.append(e.id)
	return true


func _on_update(_delta: float) -> void:
	for e: Entity in EntityMgr.get_component_group(C.CN_AURA):
		var aura_c: AuraComponent = e.get_node_or_null(C.CN_AURA)
		if aura_c.track_target:
			var target: Entity = EntityMgr.get_entity_by_id(e.target_id)
			if target:
				var new_global_position: Vector2 = target.global_position
				if target.aura_offsets:
					var offset: Vector2 = target.aura_offsets.get_offset_for_point(
						target.global_position, target.look_point
					)
					new_global_position += offset
				e.global_position = new_global_position

		if not TimeMgr.has_elapsed(aura_c.ts, aura_c.cycle_time):
			continue

		if U.is_valid_number(aura_c.max_cycle):
			if aura_c.curren_cycle > aura_c.max_cycle:
				e.remove_entity()
				continue

		var targets: Array[Entity] = aura_c.searcher.search_targets(e.global_position, e)
		for target: Entity in targets:
			aura_c.influence.take_influence(e, target, target.global_position)
			
		aura_c.ts = TimeMgr.tick_ts
		aura_c.curren_cycle += 1
		e._on_aura_cycle(targets, aura_c)


func _on_remove(e: Entity) -> bool:
	if not e.get_node_or_null(C.CN_AURA):
		return true
	
	var source: Entity = EntityMgr.get_entity_by_id(e.source_id)

	if not source:
		return true
	
	source.has_auras_id_list.erase(e.id) 
	return true