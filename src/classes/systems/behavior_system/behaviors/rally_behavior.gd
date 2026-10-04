extends Behavior
class_name RallyBehavior
## 集结点行为。
##
## RallyBehavior 负责处理拥有 [RallyComponent] 行为组件的实体的前往集结点移动。


func _on_update(entity: Entity) -> bool:
	var rally_c: RallyComponent = entity.get_node_or_null(Constants.RALLY_COMPONENT_NODE_PATH)
	if not rally_c or rally_c.arrived:
		return false
		
	if not rally_c.is_force_rally and not entity.state & (Entity.State.IDLE | Entity.State.RALLY):
		return false
		
	if rally_c.navigation_agent.is_navigation_finished():
		rally_c.arrived = true
		rally_c.is_force_rally = false
		entity.state = Entity.State.IDLE
		return false

	var next_global_position: Vector2 = rally_c.navigation_agent.get_next_path_position()
	entity.facing_global_position = next_global_position
	entity.play_animation(rally_c.config.motion_animation, &"walk")
	
	var direction: Vector2 = entity.global_position.direction_to(
		next_global_position
	)
	
	var velocity: Vector2 = (
		direction 
		* rally_c.config.speed 
		* TimeManager.frame_length
	)
	rally_c.navigation_agent.velocity = velocity
	entity.global_position += velocity
	entity.state = Entity.State.RALLY
	
	return true
