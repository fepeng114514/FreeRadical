extends System
class_name ModifierSystem
## 状态效果系统。
##
## ModifierSystem 负责处理拥有 [ModifierComponent] 状态效果组件的实体。


func _on_insert(e: Entity) -> bool:
	var modifier_c: ModifierComponent = e.get_node_or_null(C.CN_MODIFIER)
	if not modifier_c:
		return true

	var target: Entity = EntityMgr.get_entity_by_id(e.target_id)
	if not target:
		return false
		
	var interact_p: InteractPolicy = e.interact_policy
	if not InteractPolicy.is_allowed_target(e, target, interact_p, target.interact_policy):
		return false

	modifier_c.ts = TimeMgr.tick_ts
	e.global_position = target.global_position

	var same_mod_list: Array[Entity] = []
	
	for other_mod: Entity in target.get_has_mod_list():
		if other_mod == e:
			continue
			
		var other_interact_p: InteractPolicy = other_mod.interact_policy
		
		if (
			other_interact_p.is_banned(interact_p) 
			or other_interact_p.is_aura_type_banned(interact_p)
			or not other_interact_p.is_scene_allowed(e.scene_name)
		):
			return false
			
		if (
			interact_p.is_banned(other_interact_p) 
			or interact_p.is_aura_type_banned(other_interact_p)
			or not interact_p.is_scene_allowed(target.scene_name)
		):
			if modifier_c.remove_banned:
				other_mod.remove_entity()
				continue
			
			return false
		
		if other_mod.scene_name == e.scene_name:
			same_mod_list.append(other_mod)
			
	if same_mod_list and modifier_c.same_process:
		if not modifier_c.same_process.process(e, same_mod_list):
			return false

	target.has_mods_id_list.append(e.id)
	return true


func _on_update(_delta: float) -> void:
	_process_modifier_update()
	_process_property_modifiers()


func _on_remove(e: Entity) -> bool:
	var modifier_c: ModifierComponent = e.get_node_or_null(C.CN_MODIFIER)
	if not modifier_c:
		return true
	
	var target: Entity = EntityMgr.get_entity_by_id(e.target_id)
	if not target:
		return true

	var reseted_property_set: Dictionary = {}

	for property_mod: PropertyModifier in modifier_c.property_modifier_list:
		var key: Array = [property_mod.node_path, property_mod.property]
		if reseted_property_set.has(key):
			continue

		reseted_property_set[key] = true
		_reset_property(target, property_mod)

	target.has_mods_id_list.erase(e.id)

	for t_mod: Entity in target.get_has_mod_list():
		var t_modifier_c: ModifierComponent = t_mod.get_node_or_null(C.CN_MODIFIER)
		var t_property_modifier_list: Array = t_modifier_c.property_modifier_list
		
		for t_property_mod: PropertyModifier in t_property_modifier_list:
			_apply_modifier(target, t_property_mod)

	return true


## 处理状态效果的更新。
func _process_modifier_update() -> void:
	for e: Entity in EntityMgr.get_entities_group(C.GROUP_MODIFIERS):
		var modifier_c: ModifierComponent = e.get_node_or_null(C.CN_MODIFIER)

		var target: Entity = EntityMgr.get_entity_by_id(e.target_id)
		if modifier_c.track_target:
			if target:
				var new_global_position: Vector2 = target.global_position

				if target.hit_offsets:
					var offset: Vector2 = target.hit_offsets.get_offset_for_point(
						target.global_position, target.look_point
					)
					new_global_position += offset
				e.global_position = new_global_position

		if e.is_waiting():
			continue

		if modifier_c.cycle_enable:
			if U.is_valid_number(modifier_c.max_cycle):
				if modifier_c.curren_cycle > modifier_c.max_cycle:
					e.remove_entity()
					continue
			
			if TimeMgr.has_elapsed(modifier_c.ts, modifier_c.cycle_time):
				continue

			modifier_c.curren_cycle += 1
			modifier_c.ts = TimeMgr.tick_ts
			e._on_modifier_cycle(target, modifier_c)
		
			modifier_c.influence.take_influence(e, target, target.global_position)
		else:
			if not e.is_first_update:
				continue
			
			_take_influfluence(e, modifier_c, target)
		

func _take_influfluence(e: Entity, modifier_c: ModifierComponent, target: Entity) -> void:
	modifier_c.influence.take_influence(e, target, target.global_position)
	await e.y_wait_animation(e.idle_animation)

	e.remove_entity()


## 处理状态效果的属性修改。
func _process_property_modifiers() -> void:
	for e: Entity in EntityMgr.get_valid_entities():
		# 处理状态效果的属性修改
		var has_mods_id_list_size: int = e.has_mods_id_list.size()
		if e.last_has_mods_id_list_size != has_mods_id_list_size:
			e.last_has_mods_id_list_size = has_mods_id_list_size
			var reseted_property_set: Dictionary = {}

			for mod: Entity in e.get_has_mod_list():
				var modifier_c: ModifierComponent = mod.get_node_or_null(C.CN_MODIFIER)
				var property_modifier_list: Array = modifier_c.property_modifier_list

				for property_mod: PropertyModifier in property_modifier_list:
					var key: Array = [property_mod.node_path, property_mod.property]
					if not reseted_property_set.has(key):
						reseted_property_set[key] = true

						_reset_property(e, property_mod)

					_apply_modifier(e, property_mod)


## 重置实体的属性值。
func _reset_property(target: Entity, property_mod: PropertyModifier) -> void:
	var entity_data: Entity = EntityMgr.get_entity_data(load(target.scene_file_path))
	var data_node: Node = entity_data.get_node_or_null(property_mod.node_path)
	if not data_node:
		return

	var node: Node = target.get_node_or_null(property_mod.node_path)
	if not node:
		return

	var property: String = property_mod.property
	var base_value: float = data_node.get(property)
	node[property] = base_value


## 应用状态效果的属性修改。
func _apply_modifier(target: Entity, property_mod: PropertyModifier) -> void:
	var node: Node = target.get_node_or_null(property_mod.node_path)
	if not node:
		return

	var property: String = property_mod.property
	var value: float = node.get(property)
	value = property_mod.apply(value)
	node[property] = value
