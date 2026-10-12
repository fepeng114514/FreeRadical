extends System
class_name BuildSystem
## 建筑系统。
##
## [BuildSystem] 负责处理拥有 [BuildComponent] 的实体。


func _on_insert(entity: Entity) -> bool:
	var build_c: BuildComponent = entity.get_node_or_null(Constants.BUILD_COMPONENT_NODE_PATH)
	if not build_c:
		return true
		
	build_c.build_timestamp = TimeManager.tick_timestamp

	return true


func _on_update(_delta: float) -> void:
	for build: Entity in EntityManager.get_component_entity_group(Constants.BUILD_COMPONENT_NAME):
		if build.is_waiting() or build.state & Entity.State.REMOVED:
			continue

		var build_c: BuildComponent = build.get_node_or_null(Constants.BUILD_COMPONENT_NODE_PATH)
		var build_c_config: BuildComponentNodeConfig = build_c.config
		var build_progress_bar: TextureProgressBar = build_c.build_progress_bar
		var max_value: float = build_progress_bar.max_value
		
		var past_time: float = TimeManager.tick_timestamp - build_c.build_timestamp
		var value: float = past_time * max_value / build_c_config.build_time
		build_progress_bar.value = value
		
		if not TimeManager.has_elapsed(build_c.build_timestamp, build_c_config.build_time):
			continue

		var target: Entity = EntityManager.create_entity(build_c_config.build_target)
		target.global_position = build.global_position

		var record_c: RecordComponent = build.get_node_or_null(Constants.RECORD_COMPONENT_NODE_PATH)
		var new_record_c: RecordComponent = target.get_node_or_null(Constants.RECORD_COMPONENT_NODE_PATH)
		if record_c and new_record_c:
			record_c.transmit_record(new_record_c)
			
		EntityManager.queue_remove_entity(build)
		EntityManager.queue_insert_entity(target)
