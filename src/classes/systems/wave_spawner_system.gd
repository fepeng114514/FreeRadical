extends System
class_name WaveSpawnerSystem
## 波次生成器系统。
##
## WaveSpawnerSystem 负责处理拥有 [WaveSpawnerComponent] 波次生成器组件的实体，包括生成波次等。


func _on_insert(entity: Entity) -> bool:
	var wave_spawner_c: WaveSpawnerComponent = entity.get_node_or_null(Constants.CN_WAVE_SPAWNER)
	if not wave_spawner_c:
		return false

	for wave: Wave in wave_spawner_c.config.wave_group.wave_list:
		var wave_state := WaveState.new(wave)
		WaveManager.insert_wave(wave_state)

		for sub_wave: SubWave in wave.sub_wave_list:
			var sub_wave_state := SubWaveState.new(sub_wave)
			wave_state.sub_wave_queue.append(sub_wave_state)

			for spawn: WaveSpawn in sub_wave.spawn_list:
				var spawn_state := WaveSpawnState.new(spawn)
				sub_wave_state.spawn_queue.append(spawn_state)

	return true


func _on_update(_delta: float) -> void:
	for spawner: Entity in EntityManager.get_component_entity_group(Constants.CN_WAVE_SPAWNER):
		if spawner.is_waiting() or spawner.state & Entity.State.REMOVED:
			continue

		var wave_spawner_c: WaveSpawnerComponent = spawner.get_node_or_null(Constants.CN_WAVE_SPAWNER)
		var wave_state: WaveState = WaveManager.get_first_wave()
		var wave_index: int = wave_state.wave.index

		if wave_state.is_first_getted:
			Log.debug("> 开始波次计时: 波次索引: %d, 波次间隔: %.2f" % [wave_index + 1, wave_state.wave.interval])
			AudioManager.play_sfx(wave_spawner_c.config.wave_timer_start_sfx)
			WaveManager.start_wave_timer.emit(wave_index)

		# 第一个波次需要等待玩家主动释放波次
		if wave_index == 0:
			if WaveManager.need_wait_first_release_wave:
				continue
		else:
			wave_state.set_or_update_time_stamp()
			if not wave_state.is_elapsed_time(wave_state.wave.interval):
				continue

		if wave_state.is_first_elapsed_time:
			Log.debug(">>> 释放波次: %d" % (wave_index + 1))
			AudioManager.play_sfx(wave_spawner_c.config.wave_timer_finish_sfx)
			WaveManager.release_wave.emit(wave_index)

		var sub_wave_queue: Array[SubWaveState] = wave_state.sub_wave_queue
		# 子波次是并行计时的
		for sub_wave_state: SubWaveState in sub_wave_queue:
			sub_wave_state.set_or_update_time_stamp()
			if not sub_wave_state.is_elapsed_time(sub_wave_state.sub_wave.delay):
				continue

			var spawn_state: WaveSpawnState = sub_wave_state.spawn_queue[0]
			spawn_state.set_or_update_time_stamp()
			var spawn: WaveSpawn = spawn_state.spawn
			# 生成组具有两个间隔，一个是生成下一个生成组的间隔，一个是生成下一个实体的间隔
			if spawn.index != 0 and spawn_state.need_wait_interval and not spawn_state.is_elapsed_time(spawn.interval):
				spawn_state.need_wait_interval = false
				continue

			if spawn_state.spawned_total_count != 0 and not spawn_state.is_elapsed_time(spawn.spawn_interval):
				continue

			var entity: Entity = EntityManager.create_entity(spawn.entity)
			var nav_path_c: NavPathComponent = entity.get_node_or_null(Constants.CN_NAV_PATH)
			if nav_path_c:
				var sub_pathway_index: int = spawn.sub_pathway_index
				
				nav_path_c.config.reversed_enabled = spawn.reversed_enabled
				nav_path_c.config.loop_enabled = spawn.loop_enabled
				
				var node: PathwayNode = nav_path_c.get_pathway_node(
					PathwayManager.node_count - 1 if nav_path_c.config.reversed_enabled else 0
				)
				nav_path_c.set_nav_path(spawn.pathway_index, sub_pathway_index, node.index)
			
			EntityManager.queue_insert_entity(entity)
			
			spawn_state.spawned_total_count += 1
			spawn_state.time_stamp = TimeManager.tick_time_stamp

			if spawn_state.spawned_total_count >= spawn_state.spawn.count:
				spawn_state.is_finished = true

			sub_wave_state.spawn_queue.pop_front()
			if sub_wave_state.spawn_queue.size() == 0:
				sub_wave_state.is_finished = true

		wave_state.sub_wave_queue = sub_wave_queue.filter(
			func(sub_wave_state: SubWaveState) -> bool:
				return not sub_wave_state.is_finished
		)
				
		if wave_state.sub_wave_queue.size() == 0:
			WaveManager.pop_front_wave()
			Log.debug("波次释放完毕: %d" % (wave_index + 1))

		if WaveManager.queue_size() == 0 and not WaveManager.is_waves_finished:
			Log.debug("=======所有波次释放完毕=======")
			WaveManager.is_waves_finished = true
			WaveManager.waves_finished.emit()
