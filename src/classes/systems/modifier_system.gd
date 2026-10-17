extends System
class_name ModifierSystem
## 修改器系统。
##
## [ModifierSystem] 负责处理拥有 [ModifierComponent] 的实体。


func _on_insert(modifier: Entity) -> bool:
	var modifier_c: ModifierComponent = modifier.get_node_or_null(Constants.MODIFIER_COMPONENT_NODE_PATH)
	if not modifier_c:
		return true

	var modifier_c_config: ModifierComponentNodeConfig = modifier_c.config
	var target: Entity = EntityManager.get_entity_by_id(modifier_c.target_id)
	if not target:
		return false
		
	var interact_policy_c: InteractPolicyComponent = modifier.get_node_or_null(Constants.INTERACT_POLICY_COMPONENT_NODE_PATH)
	var modifier_scene_uid: String = modifier.scene_file_uid
	if interact_policy_c:
		var target_interact_policy_c: InteractPolicyComponent = target.get_node_or_null(Constants.INTERACT_POLICY_COMPONENT_NODE_PATH)
		if target_interact_policy_c:
			if target_interact_policy_c.config.modifier_type_bans & modifier_c_config.modifier_types:
				return false
			
			if not interact_policy_c.is_banned_either(target_interact_policy_c, modifier_scene_uid, target.scene_file_uid):
				return false

	modifier_c.insert_timestamp = TimeManager.tick_timestamp
	modifier.global_position = target.global_position
	var modifier_types: int = modifier_c_config.modifier_types

	var same_modifiers: Array[Entity] = []
	for other_modifier_id: int in target.has_modifiers_ids:
		var other_modifier: Entity = EntityManager.get_entity_by_id(other_modifier_id)
		if other_modifier == modifier:
			continue

		var other_modifier_scene_uid: String = other_modifier.scene_file_uid
		var exclude_modifier_scene_paths: Dictionary[String, bool] = modifier_c_config.exclude_modifier_scene_paths
		if exclude_modifier_scene_paths.has(other_modifier_scene_uid):
			if not exclude_modifier_scene_paths[other_modifier_scene_uid]:
				continue
				
			EntityManager.queue_remove_entity(other_modifier)
			continue

		var include_modifier_scene_paths: Dictionary[String, bool] = modifier_c_config.include_modifier_scene_paths
		if include_modifier_scene_paths and not include_modifier_scene_paths.has(other_modifier_scene_uid):
			if not include_modifier_scene_paths[other_modifier_scene_uid]:
				continue
 				
			EntityManager.queue_remove_entity(other_modifier)
			continue

		var is_break: bool = false
		var other_modifier_c: ModifierComponent = other_modifier.get_node_or_null(Constants.MODIFIER_COMPONENT_NODE_PATH)	
		var other_modifier_c_config: ModifierComponentNodeConfig = other_modifier_c.config
		var other_modifier_types: int = other_modifier_c_config.modifier_types
		var exclude_modifier_types: Dictionary[ModifierComponent.Type, bool] = modifier_c_config.exclude_modifier_types
		for exclude_modifier_type: ModifierComponent.Type in exclude_modifier_types.keys():
			if not exclude_modifier_type & other_modifier_types:
				continue

			if exclude_modifier_types[exclude_modifier_type]:
				EntityManager.queue_remove_entity(other_modifier)
			
			is_break = true
			break
		if is_break:
			continue

		if other_modifier_c_config.exclude_modifier_scene_paths.has(modifier_scene_uid):
			continue

		var other_include_modifier_scene_paths: Dictionary[String, bool] = other_modifier_c_config.include_modifier_scene_names
		if other_include_modifier_scene_paths and not other_include_modifier_scene_paths.has(modifier_scene_uid):
			continue
		
		is_break = false
		for exclude_modifier_type: ModifierComponent.Type in other_modifier_c_config.exclude_modifier_types.keys():
			if not exclude_modifier_type & modifier_types:
				continue

			is_break = true
			break
		if is_break:
			continue

		if other_modifier_scene_uid == modifier_scene_uid:
			same_modifiers.append(other_modifier)
			
	if same_modifiers and modifier_c_config.same_stack_policy:
		if not modifier_c_config.same_stack_policy.apply(modifier, same_modifiers):
			return false

	target.has_modifier_ids.append(modifier.id)
	target.is_modifier_ids_changed = true
	return true


func _on_update(_delta: float) -> void:
	_process_modifier_update()
	_process_property_modifiers()


func _on_remove(modifier: Entity) -> bool:
	var modifier_c: ModifierComponent = modifier.get_node_or_null(Constants.MODIFIER_COMPONENT_NODE_PATH)
	if not modifier_c:
		return true
	
	var target: Entity = EntityManager.get_entity_by_id(modifier_c.target_id)
	if not target:
		return true

	var reseted_property_set: Dictionary = {}

	for property_modifier: PropertyModifier in modifier_c.config.property_modifiers:
		var key: Array = [property_modifier.node_path, property_modifier.property]
		if reseted_property_set.has(key):
			continue

		reseted_property_set[key] = true
		_reset_property(target, property_modifier)
		
	target.has_modifier_ids.erase(modifier.id)
	target.is_modifier_ids_changed = true
	return true


## 处理修改器的更新。
func _process_modifier_update() -> void:
	for modifier: Entity in EntityManager.get_component_entity_group(Enums.ComponentFlag.MODIFIER):
		var modifier_c: ModifierComponent = modifier.get_node_or_null(Constants.MODIFIER_COMPONENT_NODE_PATH)
		var modifier_c_config: ModifierComponentNodeConfig = modifier_c.config

		var target: Entity = EntityManager.get_entity_by_id(modifier_c.target_id)
		if modifier_c_config.track_target:
			if target:
				var new_global_position: Vector2 = target.global_position
				var offset_c: OffsetComponent = target.get_node_or_null(Constants.OFFSET_COMPONENT_NODE_PATH)
				if offset_c and offset_c.config.hit_offsets:
					new_global_position += offset_c.config.hit_offsets.get_offset_toward_point(
						target.global_position, target.facing_global_position
					)
				modifier.global_position = new_global_position

		if modifier.is_waiting():
			continue
			
		if not TimeManager.has_elapsed(modifier_c.influence_timestamp, modifier_c_config.influence_interval):
			continue
		
		if Utils.is_valid_number(modifier_c_config.max_influence_count):
			if modifier_c.influence_count > modifier_c_config.max_influence_count:
				EntityManager.queue_remove_entity(modifier)
				continue
		
		if TimeManager.has_elapsed(modifier_c.influence_timestamp, modifier_c_config.influence_interval):
			continue

		modifier_c.influence_count += 1
		modifier_c.influence_timestamp = TimeManager.tick_timestamp
	
		_take_influfluence(modifier, modifier_c, target)
		

func _take_influfluence(modifier: Entity, modifier_c: ModifierComponent, target: Entity) -> void:
	var modifier_c_config: ModifierComponentNodeConfig = modifier_c.config
	var animated_sprite_c: AnimatedSpriteComponent = modifier.get_node_or_null(Constants.ANIMATED_SPRITE_COMPONENT_NODE_PATH)
	var influence_animation: FacingAnimationSet = modifier_c_config.influence_animation
	if influence_animation:
		animated_sprite_c.play_animation(modifier, influence_animation)
	await modifier.y_wait(modifier_c_config.influence_delay)
		
	modifier_c_config.influence.take_influence(modifier, target, target.global_position)
	if influence_animation:
		await animated_sprite_c.y_wait_animation(modifier, influence_animation)

	EntityManager.queue_remove_entity(modifier)


## 处理修改器的属性修改。
func _process_property_modifiers() -> void:
	for entity: Entity in EntityManager.get_valid_entities():
		if not entity.is_modifier_ids_changed:
			continue

		entity.is_modifier_ids_changed = false
		var reseted_property_set: Dictionary = {}

		for modifier_id: int in entity.has_modifier_ids:
			var modifier: Entity = EntityManager.get_entity_by_id(modifier_id)
			var modifier_c: ModifierComponent = modifier.get_node_or_null(Constants.MODIFIER_COMPONENT_NODE_PATH)
			var property_modifier_list: Array = modifier_c.config.property_modifier_list

			for property_modifier: PropertyModifier in property_modifier_list:
				var key: Array = [property_modifier.node_path, property_modifier.property]
				if not reseted_property_set.has(key):
					reseted_property_set[key] = true

					_reset_property(entity, property_modifier)

				_apply_modifier(entity, property_modifier)


## 重置实体的属性值。
func _reset_property(target: Entity, property_modifier: PropertyModifier) -> void:
	var entity_data: Entity = EntityManager.get_entity_data(target.scene_file_path)
	var data_node: Node = entity_data.get_node_or_null(property_modifier.node_path)
	if not data_node:
		return

	var node: Node = target.get_node_or_null(property_modifier.node_path)
	if not node:
		return

	var property: String = property_modifier.property
	var base_value: float = data_node.get(property)
	node[property] = base_value


## 应用修改器的属性修改。
func _apply_modifier(target: Entity, property_modifier: PropertyModifier) -> void:
	var node: Node = target.get_node_or_null(property_modifier.node_path)
	if not node:
		return

	var property: String = property_modifier.property
	var value: float = node.get(property)
	value = property_modifier.apply(value)
	node[property] = value
