extends Behavior
class_name NavPathBehavior
## 导航路径行为。
##
## NavPathBehavior 负责处理拥有 [NavPathComponent] 行为组件的实体的移动与到达终点判断。


func _on_insert(entity: Entity) -> bool:
	var nav_path_c: NavPathComponent = entity.get_node_or_null(Constants.CN_NAV_PATH)
	if not nav_path_c:
		return true

	var pathway_index: int = nav_path_c.pathway_index
	if not Utils.is_valid_number(nav_path_c.sub_pathway_index):
		nav_path_c.sub_pathway_index = PathwayManager.get_random_sub_pathway(pathway_index).index
		
	if nav_path_c.end_pathway_node_index < 0:
		nav_path_c.end_pathway_node_index = PathwayManager.node_count + nav_path_c.end_pathway_node_index

	var node: PathwayNode = nav_path_c.get_pathway_node()
	nav_path_c.navigate_to_node(node)
	entity.global_position = node.global_position

	return true


func _on_update(entity: Entity) -> bool:
	var nav_path_c: NavPathComponent = entity.get_node_or_null(Constants.CN_NAV_PATH)
	if not nav_path_c:
		return false
	
	if nav_path_c.reversed_enabled:
		return _update_reversed(entity, nav_path_c)
	else:
		return _update_forward(entity, nav_path_c)


## 更新正向移动逻辑。
func _update_forward(entity: Entity, nav_path_c: NavPathComponent) -> bool:
	var node_index: int = nav_path_c.pathway_node_index
	if node_index == nav_path_c.end_pathway_node_index:
		_arrived_end(entity, nav_path_c, false)
		return false
		
	entity.state = Entity.State.NAV_PATH_WALK
	
	var walk_length: float = nav_path_c.speed * TimeManager.frame_length
	nav_path_c.progress += walk_length
	
	var next_node_index: int = node_index
	var next_node: PathwayNode = nav_path_c.get_pathway_node(next_node_index)
	while (
		next_node_index + 1 < PathwayManager.node_count
		and nav_path_c.progress >= next_node.progress
	):
		next_node_index += 1
		next_node = nav_path_c.get_pathway_node(next_node_index)
		
	if node_index != next_node_index:
		nav_path_c.pathway_node_index = next_node_index

	var next_progress: float = nav_path_c.progress + walk_length
	_update_entity_position(entity, nav_path_c, next_progress)
	return true


## 更新反向移动逻辑。
func _update_reversed(entity: Entity, nav_path_c: NavPathComponent) -> bool:
	var node_index: int = nav_path_c.pathway_node_index
	if node_index == PathwayManager.node_count - 1 - nav_path_c.end_pathway_node_index:
		_arrived_end(entity, nav_path_c, true)
		return false
		
	entity.state = Entity.State.NAV_PATH_WALK
	
	var walk_length: float = nav_path_c.speed * TimeManager.frame_length
	nav_path_c.progress -= walk_length
	
	var next_node_index: int = node_index
	var next_node: PathwayNode = nav_path_c.get_pathway_node(next_node_index)
	while (
			next_node_index > 0 
			and nav_path_c.progress <= next_node.progress
		):
		next_node_index -= 1
		next_node = nav_path_c.get_pathway_node(next_node_index)
		
	if node_index != next_node_index:
		nav_path_c.pathway_node_index = next_node_index
	
	var next_progress: float = nav_path_c.progress - walk_length
	_update_entity_position(entity, nav_path_c, next_progress)
	return true
	

## 更新实体位置和动画。
func _update_entity_position(entity: Entity, nav_path_c: NavPathComponent, next_progress: float) -> void:
	var next_global_position: Vector2 = nav_path_c.get_progress_global_position(next_progress)
	entity.facing_global_position = next_global_position
	entity.play_animation(nav_path_c.motion_animation, "walk")
	entity.global_position = next_global_position
	
	entity.facing_global_position = nav_path_c.get_progress_global_position(next_progress)


## 到达终点处理。
func _arrived_end(entity: Entity, nav_path_c: NavPathComponent, is_reversed: bool) -> void:
	nav_path_c.reversed_enabled = not is_reversed
	
	var node: PathwayNode = nav_path_c.get_pathway_node()
	nav_path_c.navigate_to_node(node)
	
	nav_path_c.loop_count += 1
	Log.debug("到达终点: %s, 到达次数 %d" % [entity, nav_path_c.loop_count])
	
	if (
			not nav_path_c.loop_enabled 
			or Utils.is_valid_number(nav_path_c.loop_times) 
			and nav_path_c.loop_count > nav_path_c.loop_times
	):
		GameManager.life -= nav_path_c.life_cost
		ECSEntityManager.queue_remove_entity(entity)
