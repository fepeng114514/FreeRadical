extends Behavior
class_name MeleeBehavior
## 近战行为。
##
## MeleeBehavior 负责处理拥有 [MeleeComponent] 组件的实体的近战技能释放与拦截。


func _on_insert(entity: Entity) -> bool:
	var melee_c: MeleeComponent = entity.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
	if not melee_c:
		return true
	
	for skill: MeleeSkill in melee_c.get_children():
		skill.start_skill_cooldown.connect(_on_skill_cooldown_start.bind(melee_c, skill))
	
	return true


func _on_remove(entity: Entity) -> bool:
	var melee_c: MeleeComponent = entity.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
	if not melee_c:
		return true
	
	if melee_c.is_blocker:
		melee_c.blocker_unbind_melee_relations(entity)
	else:
		melee_c.blocked_unbind_melee_relations(entity)
	
	return true


func _on_skip(entity: Entity) -> void:
	var melee_c: MeleeComponent = entity.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
	if not melee_c:
		return
	
	if melee_c.is_blocker:
		melee_c.blocker_unbind_melee_relations(entity)
	else:
		melee_c.blocked_unbind_melee_relations(entity)


func _on_update(entity: Entity) -> bool:
	var melee_c: MeleeComponent = entity.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
	if not melee_c:
		return false
		
	if entity.config.interact_policy:
		if entity.config.interact_policy.flags & InteractPolicy.Flag.FRIENDLY:
			melee_c.is_blocker = true
		else:
			melee_c.is_blocker = false
			
	if entity.state & Entity.State.IDLE:
		melee_c.original_global_position = entity.global_position
	
	if melee_c.is_blocker:
		melee_c.blocker_cleanup_melee_relations(entity)
		return _update_blocker(entity, melee_c)
	else:
		melee_c.blocked_cleanup_melee_relations(entity)
		return _update_blocked(entity, melee_c)


## 更新拦截者。
func _update_blocker(entity: Entity, melee_c: MeleeComponent) -> bool:
	if melee_c.blocked_count < melee_c.config.max_blocked_count or melee_c.is_extra_blocker:
		_blocker_search_and_bind_melee_relations(entity, melee_c)
	
	var blocked_id_list: PackedInt32Array = melee_c.blocked_id_list
	if not blocked_id_list:
		match melee_c.melee_state:
			MeleeComponent.MeleeState.ORIGINAL_POSITION_ARRIVED:
				melee_c.original_global_position = entity.global_position
			_:
				if not _back_original_position(entity, melee_c):
					return true
		
		return false
	else:
		entity.state = Entity.State.MELEE
		var blocked: Entity = EntityManager.get_entity_by_id(blocked_id_list[0])
		var blocked_global_position: Vector2 = blocked.global_position
		var blocked_melee_c: MeleeComponent = blocked.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
		
		if melee_c.config.is_passive:
			if blocked_melee_c.melee_state != MeleeComponent.MeleeState.MELEE_POSITION_ARRIVED:
				entity.facing_global_position = blocked_global_position
				entity.play_animation(entity.config.idle_animation)
				return true
		else:
			var melee_global_position: Vector2 = blocked_global_position
			if blocked_melee_c.config.melee_position_offsets:
				var melee_position_offset: Vector2 = blocked_melee_c.config.melee_position_offsets.get_offset_toward_point(
					melee_global_position, entity.global_position
				)
				melee_global_position += melee_position_offset

			melee_c.melee_global_position = melee_global_position
			if not _go_melee_position(entity, melee_c, melee_global_position):
				return true
		
		_try_melee_attack(entity, melee_c, blocked)
		return true


## 拦截者搜索目标
func _blocker_search_and_bind_melee_relations(entity: Entity, melee_c: MeleeComponent) -> void:
	var center: Vector2 = entity.global_position
	var rally_c: RallyComponent = entity.get_node_or_null(Constants.RALLY_COMPONENT_NODE_PATH)
	if rally_c:
		var rally_center_global_position: Vector2 = rally_c.rally_center_global_position
		
		if rally_center_global_position:
			center = rally_center_global_position
	
	# 1. 首先搜索没有被拦截的目标
	var melee_c_config: MeleeComponentNodeConfig = melee_c.config
	var pending_blocked_list: Array[Entity] = melee_c_config.searcher.search_targets(
		center,
		entity,
		func(target: Entity) -> bool:
			var t_melee_c: MeleeComponent = target.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
			if not t_melee_c:
				return false

			if t_melee_c.config.is_passive and melee_c_config.is_passive:
				return false

			return not t_melee_c.blocker_id_list
	)
	
	if pending_blocked_list:
		# 先解除额外拦截者关系
		if melee_c.is_extra_blocker:
			if melee_c.blocked_id_list:
				var first_blocked_id: int = melee_c.blocked_id_list[0]
				var first_blocked_target: Entity = EntityManager.get_entity_by_id(first_blocked_id)
				var blocked_melee_c: MeleeComponent = first_blocked_target.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
				if blocked_melee_c.blocker_id_list.size() > 1:
					melee_c.blocked_count -= blocked_melee_c.config.block_cost
					melee_c.blocker_unbind_melee_relations(entity)

			melee_c.is_extra_blocker = false
		
		var max_blocked_count: int = melee_c_config.max_blocked_count
		for target: Entity in pending_blocked_list:
			if melee_c.blocked_count >= max_blocked_count:
				break

			var t_melee_c: MeleeComponent = target.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)

			# 如果正在拦截目标，跳过被动的目标
			if t_melee_c.config.is_passive and melee_c.blocked_id_list:
				continue
			
			melee_c.blocker_bind_melee_relations(entity.id, target.id)
	else:
		_extra_blocker_search_and_bind_melee_relations(entity, melee_c, center)


func _extra_blocker_search_and_bind_melee_relations(entity: Entity, melee_c: MeleeComponent, center: Vector2) -> void:
	if melee_c.blocked_id_list:
		return

	var melee_c_config: MeleeComponentNodeConfig = melee_c.config
	if melee_c_config.is_passive:
		return

	var blocked_targets: Array[Entity] = melee_c_config.searcher.search_targets(
		center,
		entity,
		func(target: Entity) -> bool:
			var t_melee_c: MeleeComponent = target.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
			if not t_melee_c:
				return false

			if t_melee_c.config.is_passive and melee_c_config.is_passive:
				return false
				
			return true
	)
	var first_blocked_target: Entity = blocked_targets[0] if blocked_targets else null
	if not first_blocked_target:
		return

	melee_c.blocker_bind_melee_relations(entity.id, first_blocked_target.id)
	melee_c.is_extra_blocker = true


## 更新被拦截者。
func _update_blocked(entity: Entity, melee_c: MeleeComponent) -> bool:
	var entity_global_position: Vector2 = entity.global_position
	var blocker_id_list: PackedInt32Array = melee_c.blocker_id_list
	if not blocker_id_list:
		match melee_c.melee_state:
			MeleeComponent.MeleeState.ORIGINAL_POSITION_ARRIVED:
				melee_c.original_global_position = entity_global_position
			_:
				if not _back_original_position(entity, melee_c):
					return true
		
		return false
	else:
		entity.state = Entity.State.MELEE
		var blocker: Entity = EntityManager.get_entity_by_id(blocker_id_list[0])
		var blocker_global_position: Vector2 = blocker.global_position
		var blocker_melee_c: MeleeComponent = blocker.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
		var blocker_melee_c_config: MeleeComponentNodeConfig = blocker_melee_c.config
		var is_first_blocked: bool = entity.id == blocker_melee_c.blocked_id_list[0]

		if is_first_blocked and not blocker_melee_c_config.is_passive:
			if blocker_melee_c.melee_state != MeleeComponent.MeleeState.MELEE_POSITION_ARRIVED:
				entity.facing_global_position = blocker_global_position
				entity.play_animation(entity.config.idle_animation)
				return true
		else:
			if not melee_c.config.is_passive:
				var melee_global_position: Vector2 = blocker_global_position
				if blocker_melee_c_config.melee_position_offsets:
					var melee_position_offset: Vector2 = blocker_melee_c_config.melee_position_offsets.get_offset_toward_point(
						blocker_global_position, entity_global_position
					)
					melee_global_position += melee_position_offset

				melee_c.melee_global_position = melee_global_position
				if not _go_melee_position(entity, melee_c, melee_global_position):
					return true
		
		_try_melee_attack(entity, melee_c, blocker)
		return true
	

## 前往近战位置。
func _go_melee_position(entity: Entity, melee_c: MeleeComponent, melee_global_position: Vector2) -> bool:
	if MathUtils.is_at_destination(
			entity.global_position, melee_global_position, melee_c.config.arrived_distance	 
	):
		#Log.verbose("到达近战位置，全局位置：%s, 目标点：%s, 距离：%s" % [entity.global_position, melee_c.melee_global_position, entity.global_position.distance_to(melee_c.melee_global_position)])
		melee_c.melee_state = MeleeComponent.MeleeState.MELEE_POSITION_ARRIVED
		return true
	else:
		#Log.verbose("前往近战位置，全局位置：%s, 目标点：%s, 速度：%s" % [entity.global_position, melee_c.melee_global_position, melee_c.velocity])
		melee_c.melee_state = MeleeComponent.MeleeState.MELEE_POSITION_MOVING
		var direction: Vector2 = entity.global_position.direction_to(melee_global_position)
		_move_to_direction(entity, melee_c, direction)
		return false
	

## 返回原始位置。
func _back_original_position(entity: Entity, melee_c: MeleeComponent) -> bool:
	if MathUtils.is_at_destination(
		entity.global_position, melee_c.original_global_position, melee_c.config.arrived_distance
	):
		melee_c.melee_state = MeleeComponent.MeleeState.ORIGINAL_POSITION_ARRIVED
		entity.state = Entity.State.IDLE
		return true
	else:
		melee_c.melee_state = MeleeComponent.MeleeState.ORIGINAL_POSITION_MOVING
		var direction: Vector2 = entity.global_position.direction_to(
			melee_c.original_global_position
		)
		_move_to_direction(entity, melee_c, direction)
		return false


## 将实体向指定方向移动。
func _move_to_direction(entity: Entity, melee_c: MeleeComponent, direction: Vector2) -> void:
	var velocity: Vector2 = (
		direction 
		* melee_c.config.speed 
		* TimeManager.frame_length
	)
	melee_c.velocity = velocity

	var next_global_position: Vector2 = entity.global_position + velocity
	entity.facing_global_position = next_global_position
	entity.play_animation(melee_c.config.motion_animation, &"walk")
	entity.global_position = next_global_position
	entity.facing_global_position = next_global_position + velocity


## 尝试近战技能。
func _try_melee_attack(
		entity: Entity, melee_c: MeleeComponent, target: Entity
	) -> void:
	if target:
		entity.facing_global_position = target.global_position
	entity.play_animation(entity.config.idle_animation)
	
	if not target:
		return

	for skill: MeleeSkill in melee_c.get_children():
		if not skill.can_use(entity, skill.config, target):
			continue
			
		skill.use_skill(entity, target)
		melee_c.melee_skill_used.emit(skill)
		break


func _on_skill_cooldown_start(melee_c: MeleeComponent, skill: MeleeSkill) -> void:
	melee_c.start_melee_skill_cooldown.emit(skill)
