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
		WaveMgr.wave_group = wave_group


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
		
	if not wave_group:
		warnings.append("请在 wave_group 中增加一个 WaveGroup 资源，否则无法生成波次。")
		
	return warnings


func _spawner() -> void:
	AudioMgr.play_sfx(wave_interval_start_sfx)
	WaveMgr.is_wait_first_release_wave = true
	await WaveMgr.first_release_wave
	WaveMgr.release_wave.emit(-1)
	WaveMgr.is_wait_first_release_wave = false
	
	var wave_list: Array[Wave] = wave_group.wave_list
	
	for wave_idx: int in range(WaveMgr.current_wave_idx, wave_list.size()):
		var wave: Wave = wave_list[wave_idx]
		var wave_interval: float = wave.interval
		WaveMgr.current_wave_idx = wave_idx

		WaveMgr.start_wave_timer.emit(wave_idx)
		
		if not WaveMgr.is_first_release_wave:
			AudioMgr.play_sfx(wave_interval_start_sfx)
		
		Log.debug("开始第 %d 波计时：%.2f" % [wave_idx + 1, wave_interval])
		await y_wait(wave_interval, func(): return WaveMgr.is_release_wave)
		
		WaveMgr.release_wave.emit(wave_idx)
		AudioMgr.play_sfx(wave_interval_finish_sfx)
		WaveMgr.is_release_wave = false
		Log.debug(">>> 开始第 %d 波出怪" % (wave_idx + 1))
		
		var sub_wave_list: Array[SubWave] = wave.sub_wave_list
		var sub_wave_list_size: int = sub_wave_list.size()
		var sub_wave_state_list := PackedInt32Array()
		sub_wave_state_list.resize(sub_wave_list_size)
		sub_wave_state_list.fill(SUB_WAVE_STATE_FLAGS.SPAWNING)
		
		for i: int in sub_wave_list_size:
			var sub_wave: SubWave = sub_wave_list[i]
			_spawn_sub_wave(i, sub_wave, sub_wave_state_list)
			
		await all_sub_wave_done
		WaveMgr.is_skip_wave = false
		Log.debug("-------第 %d 波释放完毕-------" % (wave_idx + 1))
			
	Log.debug("=======所有波次释放完毕=======")
	WaveMgr.waves_finished = true


func _spawn_sub_wave(
		idx: int,
		sub_wave: SubWave, 
		sub_wave_state_list: PackedInt32Array
	) -> void:
	await get_tree().physics_frame
		
	if not await y_wait(sub_wave.delay, _skip_break_fn):
		var is_break: bool = false
		
		for spawn: WaveSpawn in sub_wave.spawn_list:
			if await y_wait(spawn.interval, _skip_break_fn):
				break

			for i: int in spawn.count:
				var e: Entity = EntityMgr.create_entity(spawn.entity)
				var nav_path_c: NavPathComponent = e.get_node_or_null(C.CN_NAV_PATH)
				if nav_path_c:
					var spi: int = spawn.sub_pathway_idx
					
					nav_path_c.reversed = spawn.reversed
					nav_path_c.loop = spawn.loop
					
					var node: PathwayNode = nav_path_c.get_pathway_node(
						PathwayMgr.node_count - 1 if nav_path_c.reversed else 0
					)
					nav_path_c.set_nav_path(spawn.pathway_idx, spi, node.ni)
				
				e.insert_entity()
				
				if await y_wait(spawn.spawn_interval, _skip_break_fn):
					is_break = true
					break
					
			if is_break:
				break
	
	sub_wave_state_list[idx] = SUB_WAVE_STATE_FLAGS.DONE
	for flag: int in sub_wave_state_list:
		if not flag & SUB_WAVE_STATE_FLAGS.DONE:
			break
			
		all_sub_wave_done.emit()


func _skip_break_fn() -> bool:
	return WaveMgr.is_skip_wave
