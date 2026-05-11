extends System
class_name ModifierSystem
## 状态效果系统
##
## 处理拥有 [ModifierComponent] 状态效果组件的实体


func _on_insert(e: Entity) -> bool:
	if not e.get_node_or_null(C.CN_MODIFIER):
		return true

	var target: Entity = EntityMgr.get_entity_by_id(e.target_id)

	if not target:
		return false
		
	e.global_position = target.global_position
		
	# 检查黑白名单
	if not U.is_allowed_entity(e, target):
		return false

	# 检查是否被目标禁止
	if U.is_banned(
			target.flags,
			e.bans, 
		):
		return false
		
	var t_has_mods_id_list: PackedInt32Array = target.has_mods_id_list
	var same_target_mods: Array[Entity] = []
	var modifier_c: ModifierComponent = e.get_node_or_null(C.CN_MODIFIER)

	modifier_c.ts = TimeMgr.tick_ts

	for mod_id: int in t_has_mods_id_list:
		var other_m: Entity = EntityMgr.get_entity_by_id(mod_id)
		
		if not other_m:
			continue
		
		var other_mod_c: ModifierComponent = other_m.get_node_or_null(C.CN_MODIFIER)
		
		# 检查是否被其他效果禁止
		if U.is_mutual_ban(
				e.flags,
				other_m.bans,
				modifier_c.mod_type,
				other_m.mod_type_bans
		):
			return false
			
		# 检查是否被当前效果禁止
		if U.is_mutual_ban(
				other_m.flags,
				e.bans,
				other_mod_c.mod_type,
				e.mod_type_bans
		):
			if modifier_c.remove_banned:
				other_m.remove_entity()
				continue
			
			return false
		
		if other_m.scene_name == e.scene_name:
			same_target_mods.append(other_m)
			
	if not same_target_mods:
		t_has_mods_id_list.append(e.id)
		return true
		
	# 处理相同效果
	# 按照等级降序排序
	same_target_mods.sort_custom(
		func(m1: Entity, m2: Entity) -> bool: return m1.level > m2.level
	)
	var min_level_mod: Entity = same_target_mods[-1]
	var max_level_mod: Entity = same_target_mods[0]
		
	# 重置持续时间，优先重置等级最高的
	if modifier_c.reset_same:
		max_level_mod.insert_ts -= TimeMgr.tick_ts
		return false
	# 替换，优先替换等级最低的
	if modifier_c.replace_same:
		min_level_mod.remove_entity()
		t_has_mods_id_list.append(e.id)
		return true
	# 叠加持续时间，优先与最高等级叠加
	if modifier_c.overlay_duration_same:
		max_level_mod.insert_ts -= e.duration
		return false
	# 叠加
	if not modifier_c.allow_same:
		return false

	t_has_mods_id_list.append(e.id)
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

	var property_modifier_list: Array = modifier_c.property_modifier_list
	var reseted_property_set: Dictionary = {}

	for property_mod: PropertyModifier in property_modifier_list:
		var key: String = "%s|%s" % [property_mod.node_path, property_mod.property]
		if reseted_property_set.has(key):
			continue

		reseted_property_set[key] = true

		_reset_property(target, property_mod)

	target.has_mods_id_list.erase(e.id)
	return true


func _process_modifier_update() -> void:
	for e: Entity in EntityMgr.get_entities_group(C.GROUP_MODIFIERS):
		var modifier_c: ModifierComponent = e.get_node_or_null(C.CN_MODIFIER)
		
		# 周期效果
		if (
			U.is_valid_number(modifier_c.cycle_time) 
			and not TimeMgr.is_ready_time(modifier_c.ts, modifier_c.cycle_time)
		):
			return

		# 最大周期数
		if U.is_valid_number(modifier_c.max_cycle) and modifier_c.curren_cycle > modifier_c.max_cycle:
			e.remove_entity()
			return

		var target: Entity = EntityMgr.get_entity_by_id(e.target_id)
		
		if modifier_c.damage_min > 0 or modifier_c.damage_max > 0:
			var d := Damage.new()
			d.target_id = target.id
			d.source_id = e.id
			d.source_name = e.name
			d.value = d.get_random_value(modifier_c.damage_min, modifier_c.damage_max)
			d.damage_type = modifier_c.damage_type
			d.damage_flags = modifier_c.damage_flags
			d.insert_damage()

		e._on_modifier_period(target, modifier_c)

		modifier_c.curren_cycle += 1
		modifier_c.ts = TimeMgr.tick_ts


func _process_property_modifiers() -> void:
	for e: Entity in EntityMgr.get_valid_entities():
		# 处理状态效果的属性修改
		var has_mods_id_list_size: int = e.has_mods_id_list.size()
		if e.last_has_mods_id_list_size != has_mods_id_list_size:
			e.last_has_mods_id_list_size = has_mods_id_list_size
			var has_mod_list: Array[Entity] = e.get_has_mod_list()
			var reseted_property_set: Dictionary = {}

			# 重置属性
			for mod: Entity in has_mod_list:
				var modifier_c: ModifierComponent = mod.get_node_or_null(C.CN_MODIFIER)
				var property_modifier_list: Array = modifier_c.property_modifier_list

				for property_mod: PropertyModifier in property_modifier_list:
					var key: String = "%s|%s" % [property_mod.node_path, property_mod.property]
					if reseted_property_set.has(key):
						continue

					reseted_property_set[key] = true

					_reset_property(e, property_mod)

			# 应用属性修改
			for mod: Entity in has_mod_list:
				var modifier_c: ModifierComponent = mod.get_node_or_null(C.CN_MODIFIER)
				var property_modifier_list: Array = modifier_c.property_modifier_list

				for property_mod: PropertyModifier in property_modifier_list:
					var node: Node = e.get_node_or_null(property_mod.node_path)
					if not node:
						continue

					var property: String = property_mod.property
					var value: float = node.get(property)
					value = property_mod.apply(value)
					node.set(property, value)


func _reset_property(target: Entity, property_mod: PropertyModifier) -> void:
	var entity_data: Entity = EntityMgr.get_entity_data(target.scene_name)
	var data_node: Node = entity_data.get_node_or_null(property_mod.node_path)
	if not data_node:
		return

	var node: Node = target.get_node_or_null(property_mod.node_path)
	if not node:
		return

	var property: String = property_mod.property
	var base_value: float = data_node.get(property)
	node.set(property, base_value)