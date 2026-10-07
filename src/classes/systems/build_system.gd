extends System
class_name BuildSystem
## 建筑系统。
##
## BuildSystem 负责处理拥有 [BuildComponent] 建造组件的实体的建造逻辑。


func _on_update(_delta: float) -> void:
	for build: Entity in EntityManager.get_component_entity_group(Constants.BUILD_COMPONENT_NAME):
		if build.is_waiting() or build.state & Entity.State.REMOVED:
			continue

		var build_c: BuildComponent = build.get_node_or_null(Constants.BUILD_COMPONENT_NODE_PATH)
		var build_progress_bar: TextureProgressBar = build_c.build_progress_bar
		var max_value: float = build_progress_bar.max_value
		
		var past_time: float = TimeManager.tick_time_stamp - build.inserted_time_stamp
		var value: float = past_time * max_value / build_c.config.build_time
		build_progress_bar.value = value
		
		if not TimeManager.has_elapsed(build.inserted_time_stamp, build_c.config.build_time):
			continue

		var target: Entity = EntityManager.create_entity(build_c.config.build_target)
		target.global_position = build.global_position

		var record_c: RecordComponent = build.get_node_or_null(Constants.RECORD_COMPONENT_NODE_PATH)
		var new_record_c: RecordComponent = target.get_node_or_null(Constants.RECORD_COMPONENT_NODE_PATH)
		if record_c and new_record_c:
			record_c.transmit_record(new_record_c)
			
		EntityManager.queue_insert_entity(target)
		EntityManager.queue_remove_entity(build)
