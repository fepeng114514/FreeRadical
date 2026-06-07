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
	var t_interact_p: InteractPolicy = target.interact_policy
	if not InteractPolicy.is_allowed_target(e, target, interact_p, t_interact_p):
		return false
		
	aura_c.ts = TimeMgr.tick_ts
	e.global_position = target.global_position

	var same_aura_list: Array[Entity] = []

	for other_aura: Entity in target.get_has_aura_list():
		if other_aura == e:
			continue
		
		# 检查是否被其他光环禁止
		if (
			t_interact_p.is_banned(interact_p) 
			or t_interact_p.is_aura_type_banned(interact_p)
			or not t_interact_p.is_scene_allowed(e.scene_name)
		):
			return false
		
		# 检查是否被当前光环禁止
		if (
			interact_p.is_banned(t_interact_p) 
			or interact_p.is_aura_type_banned(t_interact_p)
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
	for e: Entity in EntityMgr.get_entities_group(C.GROUP_AURAS):
		var aura_c: AuraComponent = e.get_node_or_null(C.CN_AURA)

		# 周期效果
		if not TimeMgr.has_elapsed(aura_c.ts, aura_c.cycle_time):
			return

		# 最大周期数
		if U.is_valid_number(aura_c.max_cycle):
			if aura_c.curren_cycle > aura_c.max_cycle:
				e.remove_entity()
				return

		var targets: Array[Entity] = aura_c.search.search_targets(e, e.global_position)
		for target: Entity in targets:
			aura_c.influence.take_influence(e, target, target.global_position)

		e._on_aura_period(targets, aura_c)

		aura_c.curren_cycle += 1
		aura_c.ts = TimeMgr.tick_ts


func _on_remove(e: Entity) -> bool:
	if not e.get_node_or_null(C.CN_AURA):
		return true
	
	var source: Entity = EntityMgr.get_entity_by_id(e.source_id)

	if not source:
		return true
	
	source.has_auras_id_list.erase(e.id) 
	return true
