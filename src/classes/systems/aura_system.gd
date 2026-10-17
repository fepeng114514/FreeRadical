extends System
class_name AuraSystem
## 光环系统。
##
## [AuraSystem] 负责处理拥有 [AuraComponent] 的实体。


func _on_insert(aura: Entity) -> bool:
	var aura_c: AuraComponent = aura.get_node_or_null(Constants.AURA_COMPONENT_NODE_PATH)
	if not aura_c:
		return true
		
	var aura_c_config: AuraComponentNodeConfig = aura_c.config
	var target: Entity = EntityManager.get_entity_by_id(aura_c.target_id)
	if not target:
		return false

	var interact_policy_c: InteractPolicyComponent = aura.get_node_or_null(Constants.INTERACT_POLICY_COMPONENT_NODE_PATH)
	var aura_scene_uid: String = aura_c.scene_file_uid
	if interact_policy_c:
		var target_interact_policy_c: InteractPolicyComponent = target.get_node_or_null(Constants.INTERACT_POLICY_COMPONENT_NODE_PATH)
		if target_interact_policy_c:
			if target_interact_policy_c.config.aura_type_bans & aura_c_config.aura_types:
				return false

			if interact_policy_c.is_banned_either(target_interact_policy_c, aura_scene_uid, target.scene_file_uid):
				return false
		
	aura_c.insert_timestamp = TimeManager.tick_timestamp
	aura.global_position = target.global_position
	var aura_types: int = aura_c_config.aura_types

	var same_aura_list: Array[Entity] = []
	for other_aura_id: int in target.has_auras_ids:
		var other_aura: Entity = EntityManager.get_entity_by_id(other_aura_id)
		if other_aura == aura:
			continue

		var other_aura_scene_uid: String = other_aura.scene_file_uid
		var exclude_aura_scene_paths: Dictionary[String, bool] = aura_c_config.exclude_aura_scene_paths
		if exclude_aura_scene_paths.has(other_aura_scene_uid):
			if not exclude_aura_scene_paths[other_aura_scene_uid]:
				continue

			EntityManager.queue_remove_entity(other_aura)
			continue

		var include_aura_scene_paths: Dictionary[String, bool] = aura_c_config.include_aura_scene_paths
		if include_aura_scene_paths and not include_aura_scene_paths.has(other_aura_scene_uid):
			if not include_aura_scene_paths[other_aura_scene_uid]:
				continue
				
			EntityManager.queue_remove_entity(other_aura)
			continue

		var is_break: bool = false
		var other_aura_c: AuraComponent = other_aura.get_node_or_null(Constants.AURA_COMPONENT_NODE_PATH)	
		var other_aura_c_config: AuraComponentNodeConfig = other_aura_c.config
		var other_aura_types: int = other_aura_c_config.aura_types
		var exclude_aura_types: Dictionary[AuraComponent.Type, bool] = aura_c_config.exclude_aura_types
		for exclude_aura_type: AuraComponent.Type in exclude_aura_types.keys():
			if not exclude_aura_type & other_aura_types:
				continue

			if exclude_aura_types[exclude_aura_type]:
				EntityManager.queue_remove_entity(other_aura)
			
			is_break = true
			break
		if is_break:
			continue

		if other_aura_c_config.exclude_aura_scene_paths.has(aura_scene_uid):
			continue

		var other_include_aura_scene_paths: Dictionary[String, bool] = other_aura_c_config.include_aura_scene_paths
		if other_include_aura_scene_paths and not other_include_aura_scene_paths.has(aura_scene_uid):
			continue
		
		is_break = false
		for exclude_aura_type: AuraComponent.Type in other_aura_c_config.exclude_aura_types.keys():
			if not exclude_aura_type & other_aura_types:
				continue

			is_break = true
			break
		if is_break:
			continue

		if other_aura_scene_uid == aura_scene_uid:
			same_aura_list.append(other_aura)
			
	if same_aura_list and aura_c_config.same_stack_policy:
		if not aura_c_config.same_stack_policy.apply(aura, same_aura_list):
			return false

	target.has_auras_ids.append(aura.id)

	return true


func _on_update(_delta: float) -> void:
	for aura: Entity in EntityManager.get_component_entity_group(Enums.ComponentFlag.AURA):
		var aura_c: AuraComponent = aura.get_node_or_null(Constants.AURA_COMPONENT_NODE_PATH)
		var aura_c_config: AuraComponentNodeConfig = aura_c.config
		if aura_c_config.track_target:
			var target: Entity = EntityManager.get_entity_by_id(aura_c.target_id)
			if target:
				var new_global_position: Vector2 = target.global_position
				var offset_c: OffsetComponent = target.get_node_or_null(Constants.OFFSET_COMPONENT_NODE_PATH)
				if offset_c and offset_c.config.aura_offsets:
					new_global_position += offset_c.config.aura_offsets.get_offset_toward_point(
						target.global_position, target.facing_global_position
					)
				aura.global_position = new_global_position

		if aura.is_waiting():
			continue

		if not TimeManager.has_elapsed(aura_c.influence_timestamp, aura_c_config.influence_interval):
			continue

		if Utils.is_valid_number(aura_c_config.max_influence_count):
			if aura_c.current_influence_count > aura_c_config.max_influence_count:
				EntityManager.queue_remove_entity(aura)
				continue

		_take_influfluence(aura, aura_c)
			
		aura_c.influence_timestamp = TimeManager.tick_timestamp
		aura_c.current_influence_count += 1


func _on_remove(aura: Entity) -> bool:
	if not aura.get_node_or_null(Constants.AURA_COMPONENT_NODE_PATH):
		return true
	
	var source: Entity = EntityManager.get_entity_by_id(aura.source_id)

	if not source:
		return true
	
	source.has_auras_ids.erase(aura.id) 
	return true


func _take_influfluence(aura: Entity, aura_c: AuraComponent) -> void:
	var aura_c_config: AuraComponentNodeConfig = aura_c.config
	var animated_sprite_c: AnimatedSpriteComponent = aura.get_node_or_null(Constants.ANIMATED_SPRITE_COMPONENT_NODE_PATH)
	var influence_animation: FacingAnimationSet = aura_c_config.influence_animation
	if influence_animation:
		animated_sprite_c.play_animation(aura, influence_animation)
	await aura.y_wait(aura_c_config.influence_delay)
	
	var filter: Callable = func(target: Entity) -> bool:
		var interact_policy_c: InteractPolicyComponent = target.get_node_or_null(Constants.INTERACT_POLICY_COMPONENT_NODE_PATH)
		if not interact_policy_c:
			return true

		if interact_policy_c.config.aura_type_bans & aura_c_config.aura_types:
			return false

		return true
	var targets: Array[Entity] = aura_c_config.searcher.search_targets(aura.global_position, aura, filter)
	for target: Entity in targets:
		aura_c_config.influence.take_influence(aura, target, target.global_position)

	if influence_animation:
		await animated_sprite_c.y_wait_animation(aura, influence_animation)

	EntityManager.queue_remove_entity(aura)
