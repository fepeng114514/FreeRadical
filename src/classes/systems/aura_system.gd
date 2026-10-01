extends System
class_name AuraSystem
## 光环系统。
##
## AuraSystem 负责处理拥有 [AuraComponent] 光环组件的实体。


func _on_insert(aura: Entity) -> bool:
	var aura_c: AuraComponent = aura.get_node_or_null(Constants.CN_AURA)
	if not aura_c:
		return true
		
	var target: Entity = EntityManager.get_entity_by_id(aura.target_id)
	if not target:
		return false

	var interact_policy: InteractPolicy = aura.config.interact_policy
	if not InteractPolicy.is_allowed_target(aura, target, interact_policy, target.config.interact_policy):
		return false
		
	aura_c.time_stamp = TimeManager.tick_time_stamp
	aura.global_position = target.global_position

	var same_aura_list: Array[Entity] = []

	for other_aura: Entity in target.get_has_aura_list():
		if other_aura == aura:
			continue

		var other_interact_policy: InteractPolicy = other_aura.config.interact_policy
		
		# 检查是否被其他光环禁止
		if (
			other_interact_policy.is_banned(interact_policy) 
			or other_interact_policy.is_aura_type_banned(interact_policy)
			or not other_interact_policy.is_scene_allowed(aura.scene_name)
		):
			return false
		
		# 检查是否被当前光环禁止
		if (
			interact_policy.is_banned(other_interact_policy) 
			or interact_policy.is_aura_type_banned(other_interact_policy)
			or not interact_policy.is_scene_allowed(target.scene_name)
		):
			if aura_c.config.remove_banned:
				EntityManager.queue_remove_entity(other_aura)
				continue
			
			return false
		
		if other_aura.scene_name == aura.scene_name:
			same_aura_list.append(other_aura)	
			
	if same_aura_list and aura_c.config.same_process:
		if not aura_c.config.same_process.process(aura, same_aura_list):
			return false

	target.has_auras_id_list.append(aura.id)
	return true


func _on_update(_delta: float) -> void:
	for aura: Entity in EntityManager.get_component_entity_group(Constants.CN_AURA):
		var aura_c: AuraComponent = aura.get_node_or_null(Constants.CN_AURA)
		if aura_c.config.track_target:
			var target: Entity = EntityManager.get_entity_by_id(aura.target_id)
			if target:
				var new_global_position: Vector2 = target.global_position
				if target.config.aura_offsets:
					var offset: Vector2 = target.config.aura_offsets.get_offset_toward_point(
						target.global_position, target.facing_global_position
					)
					new_global_position += offset
				aura.global_position = new_global_position

		if not TimeManager.has_elapsed(aura_c.time_stamp, aura_c.config.cycle_time):
			continue

		if Utils.is_valid_number(aura_c.config.max_cycle):
			if aura_c.curren_cycle > aura_c.config.max_cycle:
				EntityManager.queue_remove_entity(aura)
				continue

		var targets: Array[Entity] = aura_c.config.searcher.search_targets(aura.global_position, aura)
		for target: Entity in targets:
			aura_c.config.influence.take_influence(aura, target, target.global_position)
			
		aura_c.time_stamp = TimeManager.tick_time_stamp
		aura_c.curren_cycle += 1


func _on_remove(aura: Entity) -> bool:
	if not aura.get_node_or_null(Constants.CN_AURA):
		return true
	
	var source: Entity = EntityManager.get_entity_by_id(aura.source_id)

	if not source:
		return true
	
	source.has_auras_id_list.erase(aura.id) 
	return true
