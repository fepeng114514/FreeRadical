extends System
class_name DurationSystem
## 持续时间系统。
##
## [DurationSystem] 负责处理拥有 [DurationComponent] 的实体。


func _on_insert(entity: Entity) -> bool:
	var duration_c: DurationComponent = entity.get_node_or_null(Constants.DURATION_COMPONENT_NODE_PATH)
	if not duration_c:
		return true
	
	duration_c.duration_timestamp = TimeManager.tick_timestamp
		
	return true


func _on_update(_delta: float) -> void:
	for entity: Entity in EntityManager.get_component_entity_group(Constants.DURATION_COMPONENT_NAME):
		var duration_c: DurationComponent = entity.get_node_or_null(Constants.DURATION_COMPONENT_NODE_PATH)
		if not duration_c:
			continue

		if Utils.is_valid_number(duration_c.config.duration) and TimeManager.has_elapsed(duration_c.duration_timestamp, duration_c.config.duration):
			EntityManager.queue_remove_entity(entity)
