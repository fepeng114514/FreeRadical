extends System
class_name BuildSystem
## 建筑系统。
##
## BuildSystem 负责处理拥有 [BuildComponent] 建造组件的实体的建造逻辑。


func _on_update(_delta: float) -> void:
	for build: Entity in EntityManager.get_component_entity_group(Constants.CN_BUILD):
		if build.is_waiting() or build.state & Entity.State.REMOVED:
			continue

		var build_c: BuildComponent = build.get_node_or_null(Constants.CN_BUILD)
		var build_progress_bar: TextureProgressBar = build_c.build_progress_bar
		var max_value: float = build_progress_bar.max_value
		
		var past_time: float = TimeManager.tick_time_stamp - build.inserted_time_stamp
		var value: float = past_time * max_value / build_c.build_time
		build_progress_bar.value = value
		
		if not TimeManager.has_elapsed(build.inserted_time_stamp, build_c.build_time):
			continue

		var price: float = build_c.price
		var target: Entity = EntityManager.create_entity(build_c.build_target)
		target.set_global_position_with_components(build.global_position)
		EntityManager.queue_insert_entity(target)
		EntityManager.queue_remove_entity(build)
		GameManager.cash -= price
