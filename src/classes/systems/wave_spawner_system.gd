extends System
class_name WaveSpawnerSystem
## 波次生成器系统。
##
## WaveSpawnerSystem 负责处理拥有 [WaveSpawnerComponent] 波次生成器组件的实体，包括生成波次等。


func _on_ready(entity: Entity) -> void:
	var wave_spawner_c: WaveSpawnerComponent = entity.get_node_or_null(Constants.WAVE_SPAWNER_COMPONENT_NODE_PATH)
	if not wave_spawner_c:
		return

	WaveManager.wave_group = wave_spawner_c.config.wave_group
	for wave: Wave in wave_spawner_c.config.wave_group.wave_list:
		wave_spawner_c.wave_queue.append(wave)

		for sub_wave: SubWave in wave.sub_wave_list:
			wave.sub_wave_queue.append(sub_wave)

			for spawn: WaveSpawn in sub_wave.spawn_list:
				sub_wave.spawn_queue.append(spawn)


func _on_update(_delta: float) -> void:
	for spawner: Entity in EntityManager.get_component_entity_group(Constants.WAVE_SPAWNER_COMPONENT_NAME):
		if spawner.is_waiting() or spawner.state & Entity.State.REMOVED:
			continue

		if WaveManager.is_waves_finished:
			continue

		var wave_spawner_c: WaveSpawnerComponent = spawner.get_node_or_null(Constants.WAVE_SPAWNER_COMPONENT_NODE_PATH)
		var wave_queue: Array[Wave] = wave_spawner_c.wave_queue
		var wave: Wave = wave_queue[0]
		var wave_index: int = wave.index
		WaveManager.current_wave_index = wave_index

		if wave.is_first_getted:
			wave.is_first_getted = false
			Log.debug("> 开始波次计时: 波次索引: %d, 波次间隔: %.2f" % [wave_index + 1, wave.interval])
			AudioManager.play_sfx(wave_spawner_c.config.wave_timer_start_sfx)

			var wave_list: Array[Wave] = wave_spawner_c.config.wave_group.wave_list
			for sub_wave: SubWave in wave_list[wave_index].sub_wave_list:
				for spawn: WaveSpawn in sub_wave.spawn_list:
					WaveManager.current_wave_pathway_indexes.append(spawn.pathway_index)
			
			WaveManager.wave_timer_started.emit(wave_index)
			WaveManager.is_release_wave = false
			WaveManager.can_emit_wave_timer_finished = true

		if WaveManager.is_skip_wave:
			WaveManager.is_skip_wave = false
			wave_queue.pop_front()
			Log.debug("跳过波次: %d" % (wave_index + 1))
		else:
			# 第一个波次需要等待玩家主动释放
			if wave_index == 0:
				if not WaveManager.is_release_wave:
					continue

				if WaveManager.can_emit_first_wave_released:
					WaveManager.can_emit_first_wave_released = false
					WaveManager.first_wave_released.emit()
			else:
				wave.try_set_time_stamp()
				if not wave.is_elapsed_time(wave.interval) and not WaveManager.is_release_wave:
					WaveManager.wave_timer_progress.emit(TimeManager.tick_time_stamp - wave.time_stamp / wave.interval)
					continue

			if WaveManager.can_emit_wave_timer_finished:
				WaveManager.can_emit_wave_timer_finished = false
				WaveManager.wave_timer_finished.emit()

			if wave.is_first_elapsed_time:
				wave.is_first_elapsed_time = false
				Log.debug(">>> 释放波次: %d" % (wave_index + 1))
				AudioManager.play_sfx(wave_spawner_c.config.wave_timer_finish_sfx)
				WaveManager.wave_released.emit(wave_index)

			_process_sub_wave(wave)

			wave.sub_wave_queue = wave.sub_wave_queue.filter(
				func(sub_wave: SubWave) -> bool:
					return not sub_wave.is_finished
			)
					
			if wave.sub_wave_queue.size() == 0:
				wave_queue.pop_front()
				Log.debug("波次释放完毕: %d" % (wave_index + 1))

		if wave_queue.size() == 0 and not WaveManager.is_waves_finished:
			Log.debug("=======所有波次释放完毕=======")
			WaveManager.is_waves_finished = true
			WaveManager.waves_finished.emit()


func _process_sub_wave(wave: Wave) -> void:
	var sub_wave_queue: Array[SubWave] = wave.sub_wave_queue
	# 子波次是并行计时的
	for sub_wave: SubWave in sub_wave_queue:
		sub_wave.try_set_time_stamp()
		if not sub_wave.is_elapsed_time(sub_wave.delay):
			continue

		var spawn: WaveSpawn = sub_wave.spawn_queue[0]
		spawn.try_set_time_stamp()
		# 生成组具有两个间隔，一个是生成下一个生成组的间隔，一个是生成下一个实体的间隔
		if spawn.index != 0 and spawn.need_wait_interval and not spawn.is_elapsed_time(spawn.interval):
			spawn.need_wait_interval = false
			continue

		if spawn.spawned_total_count != 0 and not spawn.is_elapsed_time(spawn.spawn_interval):
			continue

		var entity: Entity = EntityManager.create_entity(spawn.entity)
		var nav_path_c: NavPathComponent = entity.get_node_or_null(Constants.NAV_PATH_COMPONENT_NODE_PATH)
		if nav_path_c:
			var sub_pathway_index: int = spawn.sub_pathway_index
			
			nav_path_c.config.reversed_enabled = spawn.reversed_enabled
			nav_path_c.config.loop_enabled = spawn.loop_enabled
			
			var node: PathwayNode = nav_path_c.get_pathway_node(
				PathwayManager.node_count - 1 if nav_path_c.config.reversed_enabled else 0
			)
			nav_path_c.set_nav_path(spawn.pathway_index, sub_pathway_index, node.index)
		
		EntityManager.queue_insert_entity(entity)
		
		spawn.spawned_total_count += 1
		spawn.time_stamp = TimeManager.tick_time_stamp

		if spawn.spawned_total_count >= spawn.count:
			spawn.is_finished = true
			sub_wave.spawn_queue.pop_front()

		if sub_wave.spawn_queue.size() == 0:
			sub_wave.is_finished = true
