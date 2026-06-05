@tool
extends Control


func _ready() -> void:
	if Engine.is_editor_hint():
		pass
	else:
		var wave: Wave = WaveMgr.wave_group.wave_list[WaveMgr.current_wave_idx]
		var child_count: int = get_child_count()

		for sub_wave: SubWave in wave.sub_wave_list:
			for spawn: WaveSpawn in sub_wave.spawn_list:
				if spawn.pathway_idx >= child_count:
					Log.error("wave_flag_container: 波次标识索引超出范围，索引：%d，波次标识数量：%d" % [spawn.pathway_idx, child_count])
					break

				var wave_flag: WaveFlag = get_child(spawn.pathway_idx)
				wave_flag.visible = true

		WaveMgr.start_wave_timer.connect(_on_start_wave_timer)


func _on_start_wave_timer(wave_idx: int) -> void:
	var wave: Wave = WaveMgr.wave_group.wave_list[wave_idx]
	var child_count: int = get_child_count()
	var wave_interval: float = wave.interval

	for sub_wave: SubWave in wave.sub_wave_list:
		for spawn: WaveSpawn in sub_wave.spawn_list:
			if spawn.pathway_idx >= child_count:
				Log.error("wave_flag_container: 波次标识索引超出范围，索引：%d，波次标识数量：%d" % [spawn.pathway_idx, child_count])
				break

			var wave_flag: WaveFlag = get_child(spawn.pathway_idx)
			wave_flag._show(wave_interval)


func _get_configuration_warnings() -> PackedStringArray:
	var warn: PackedStringArray = []
	
	if not get_children():
		warn.append("请至少增加一个 WaveFlag 子节点，否则无法显示波次到来时间。")
		
	return warn
