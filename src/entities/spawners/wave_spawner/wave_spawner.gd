@tool
extends Entity


signal all_sub_wave_done


enum SUB_WAVE_STATE_FLAGS {
	SPAWNING,
	DONE,
}


@export var wave_group: WaveGroup = null:
	set(v):
		wave_group = v
		update_configuration_warnings()
		
@export var wave_interval_start_sfx: AudioGroup = null
@export var wave_interval_finish_sfx: AudioGroup = null


func _ready() -> void:
	if Engine.is_editor_hint():
		pass
	else:
		WaveManager.wave_group = wave_group
		WaveManager.wave_spawner = self


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
		
	if not wave_group:
		warnings.append("请在 wave_group 中增加一个 WaveGroup 资源，否则无法生成波次。")
		
	return warnings


func _spawner() -> void:
	AudioManager.play_sfx(wave_interval_start_sfx)
	WaveManager.is_wait_first_release_wave = true
	await WaveManager.first_release_wave
	WaveManager.release_wave.emit(-1)
	WaveManager.is_wait_first_release_wave = false
	
	var wave_list: Array[Wave] = wave_group.wave_list
	
	for wave_index: int in range(WaveManager.current_wave_index, wave_list.size()):
		var wave: Wave = wave_list[wave_index]
		var wave_interval: float = wave.interval
		WaveManager.current_wave_index = wave_index

		WaveManager.start_wave_timer.emit(wave_index)
		
		if not WaveManager.is_first_release_wave:
			AudioManager.play_sfx(wave_interval_start_sfx)
		
		Log.debug("开始第 %d 波计时：%.2f" % [wave_index + 1, wave_interval])
		await y_wait(wave_interval, func(): return WaveManager.is_release_wave)
		
		WaveManager.release_wave.emit(wave_index)
		AudioManager.play_sfx(wave_interval_finish_sfx)
		WaveManager.is_release_wave = false
		Log.debug(">>> 开始第 %d 波出怪" % (wave_index + 1))
		
		var sub_wave_list: Array[SubWave] = wave.sub_wave_list
		var sub_wave_list_size: int = sub_wave_list.size()
		var sub_wave_state_list := PackedInt32Array()
		sub_wave_state_list.resize(sub_wave_list_size)
		sub_wave_state_list.fill(SUB_WAVE_STATE_FLAGS.SPAWNING)
		
		for sub_wave_index: int in sub_wave_list_size:
			var sub_wave: SubWave = sub_wave_list[sub_wave_index]
			_spawn_sub_wave(sub_wave_index, sub_wave, sub_wave_state_list)
			
		await all_sub_wave_done
		WaveManager.is_skip_wave = false
		Log.debug("-------第 %d 波释放完毕-------" % (wave_index + 1))
			
	Log.debug("=======所有波次释放完毕=======")
	WaveManager.waves_finished = true


func _spawn_sub_wave(
		index: int,
		sub_wave: SubWave, 
		sub_wave_state_list: PackedInt32Array
	) -> void:
	await get_tree().physics_frame
		
	if not await y_wait(sub_wave.delay, _skip_break_fn):
		var is_break: bool = false
		
		for spawn: WaveSpawn in sub_wave.spawn_list:
			if await y_wait(spawn.interval, _skip_break_fn):
				break

			for spawn_index: int in spawn.count:
				var entity: Entity = ECSEntityManager.create_entity(spawn.entity)
				var nav_path_c: NavPathComponent = entity.get_node_or_null(Constants.CN_NAV_PATH)
				if nav_path_c:
					var sub_pathway_index: int = spawn.sub_pathway_index
					
					nav_path_c.reversed_enabled = spawn.reversed_enabled
					nav_path_c.loop_enabled = spawn.loop_enabled
					
					var node: PathwayNode = nav_path_c.get_pathway_node(
						PathwayManager.node_count - 1 if nav_path_c.reversed_enabled else 0
					)
					nav_path_c.set_nav_path(spawn.pathway_index, sub_pathway_index, node.index)
				
				ECSEntityManager.queue_insert_entity(entity)
				
				if await y_wait(spawn.spawn_interval, _skip_break_fn):
					is_break = true
					break
					
			if is_break:
				break
	
	sub_wave_state_list[index] = SUB_WAVE_STATE_FLAGS.DONE
	for flag: int in sub_wave_state_list:
		if not flag & SUB_WAVE_STATE_FLAGS.DONE:
			break
			
		all_sub_wave_done.emit()


func _skip_break_fn() -> bool:
	return WaveManager.is_skip_wave
