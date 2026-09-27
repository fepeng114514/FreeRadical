extends ECSSystem
class_name ModifierSystem
## 状态效果系统。
##
## ModifierSystem 负责处理拥有 [ModifierComponent] 状态效果组件的实体。


func _on_insert(modifier: ECSEntity) -> bool:
	modifier = modifier as Entity

	var modifier_c: ModifierComponent = modifier.get_node_or_null(Constants.CN_MODIFIER)
	if not modifier_c:
		return true

	var target: Entity = ECSEntityManager.get_entity_by_id(modifier.target_id)
	if not target:
		return false
		
	var interact_policy: InteractPolicy = modifier.interact_policy
	if not InteractPolicy.is_allowed_target(modifier, target, interact_policy, target.interact_policy):
		return false

	modifier_c.time_stamp = TimeManager.tick_time_stamp
	modifier.global_position = target.global_position

	var same_modifier_list: Array[Entity] = []
	
	for other_modifier: Entity in target.get_has_mod_list():
		if other_modifier == modifier:
			continue
			
		var other_interact_policy: InteractPolicy = other_modifier.interact_policy
		
		if (
			other_interact_policy.is_banned(interact_policy) 
			or other_interact_policy.is_aura_type_banned(interact_policy)
			or not other_interact_policy.is_scene_allowed(modifier.scene_name)
		):
			return false
			
		if (
			interact_policy.is_banned(other_interact_policy) 
			or interact_policy.is_aura_type_banned(other_interact_policy)
			or not interact_policy.is_scene_allowed(target.scene_name)
		):
			if modifier_c.remove_banned:
				ECSEntityManager.queue_remove_entity(other_modifier)
				continue
			
			return false
		
		if other_modifier.scene_name == modifier.scene_name:
			same_modifier_list.append(other_modifier)
			
	if same_modifier_list and modifier_c.same_process:
		if not modifier_c.same_process.process(modifier, same_modifier_list):
			return false

	target.has_mods_id_list.append(modifier.id)
	return true


func _on_update(_delta: float) -> void:
	_process_modifier_update()
	_process_property_modifiers()


func _on_remove(modifier: ECSEntity) -> bool:
	modifier = modifier as Entity
	
	var modifier_c: ModifierComponent = modifier.get_node_or_null(Constants.CN_MODIFIER)
	if not modifier_c:
		return true
	
	var target: Entity = ECSEntityManager.get_entity_by_id(modifier.target_id)
	if not target:
		return true

	var reseted_property_set: Dictionary = {}

	for property_mod: PropertyModifier in modifier_c.property_modifier_list:
		var key: Array = [property_mod.node_path, property_mod.property]
		if reseted_property_set.has(key):
			continue

		reseted_property_set[key] = true
		_reset_property(target, property_mod)

	target.has_mods_id_list.erase(modifier.id)

	for t_mod: Entity in target.get_has_mod_list():
		var t_modifier_c: ModifierComponent = t_mod.get_node_or_null(Constants.CN_MODIFIER)
		var t_property_modifier_list: Array = t_modifier_c.property_modifier_list
		
		for t_property_mod: PropertyModifier in t_property_modifier_list:
			_apply_modifier(target, t_property_mod)

	return true


## 处理状态效果的更新。
func _process_modifier_update() -> void:
	for modifier: Entity in ECSEntityManager.get_component_entity_group(Constants.CN_MODIFIER):
		var modifier_c: ModifierComponent = modifier.get_node_or_null(Constants.CN_MODIFIER)

		var target: Entity = ECSEntityManager.get_entity_by_id(modifier.target_id)
		if modifier_c.track_target:
			if target:
				var new_global_position: Vector2 = target.global_position

				if target.hit_offsets:
					var offset: Vector2 = target.hit_offsets.get_offset_toward_point(
						target.global_position, target.facing_global_position
					)
					new_global_position += offset
				modifier.global_position = new_global_position

		if modifier.is_waiting():
			continue

		if modifier_c.cycle_enabled:
			if Utils.is_valid_number(modifier_c.max_cycle):
				if modifier_c.curren_cycle > modifier_c.max_cycle:
					ECSEntityManager.queue_remove_entity(modifier)
					continue
			
			if TimeManager.has_elapsed(modifier_c.time_stamp, modifier_c.cycle_time):
				continue

			modifier_c.curren_cycle += 1
			modifier_c.time_stamp = TimeManager.tick_time_stamp
		
			modifier_c.influence.take_influence(modifier, target, target.global_position)
		else:
			if not modifier.is_first_update:
				continue
			
			_take_influfluence(modifier, modifier_c, target)
		

func _take_influfluence(modifier: Entity, modifier_c: ModifierComponent, target: Entity) -> void:
	modifier_c.influence.take_influence(modifier, target, target.global_position)
	await modifier.y_wait_animation(modifier.idle_animation)

	ECSEntityManager.queue_remove_entity(modifier)


## 处理状态效果的属性修改。
func _process_property_modifiers() -> void:
	for entity: Entity in ECSEntityManager.get_valid_entities():
		var has_mods_id_list_size: int = entity.has_mods_id_list.size()
		if entity.last_has_mods_id_list_size != has_mods_id_list_size:
			entity.last_has_mods_id_list_size = has_mods_id_list_size
			var reseted_property_set: Dictionary = {}

			for modifier: Entity in entity.get_has_mod_list():
				var modifier_c: ModifierComponent = modifier.get_node_or_null(Constants.CN_MODIFIER)
				var property_modifier_list: Array = modifier_c.property_modifier_list

				for property_modifier: PropertyModifier in property_modifier_list:
					var key: Array = [property_modifier.node_path, property_modifier.property]
					if not reseted_property_set.has(key):
						reseted_property_set[key] = true

						_reset_property(entity, property_modifier)

					_apply_modifier(entity, property_modifier)


## 重置实体的属性值。
func _reset_property(target: Entity, property_modifier: PropertyModifier) -> void:
	var entity_data: Entity = ECSEntityManager.get_entity_data(target.scene_file_path)
	var data_node: Node = entity_data.get_node_or_null(property_modifier.node_path)
	if not data_node:
		return

	var node: Node = target.get_node_or_null(property_modifier.node_path)
	if not node:
		return

	var property: String = property_modifier.property
	var base_value: float = data_node.get(property)
	node[property] = base_value


## 应用状态效果的属性修改。
func _apply_modifier(target: Entity, property_modifier: PropertyModifier) -> void:
	var node: Node = target.get_node_or_null(property_modifier.node_path)
	if not node:
		return

	var property: String = property_modifier.property
	var value: float = node.get(property)
	value = property_modifier.apply(value)
	node[property] = value
