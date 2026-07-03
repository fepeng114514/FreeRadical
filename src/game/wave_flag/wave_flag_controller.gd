@tool
extends Control


var wave_flag_dict: Dictionary[Pathway, WaveFlag] = {}


func _ready() -> void:
	if Engine.is_editor_hint():
		pass
	else:
		for child: WaveFlag in get_children():
			wave_flag_dict[child.pathway_node] = child
		
		var wave: Wave = WaveMgr.wave_group.wave_list[WaveMgr.current_wave_idx]
	
		for sub_wave: SubWave in wave.sub_wave_list:
			for spawn: WaveSpawn in sub_wave.spawn_list:
				var bound_pathway_node: Pathway = PathwayMgr.get_pathway(spawn.pathway_idx)
				var wave_flag: WaveFlag = wave_flag_dict[bound_pathway_node]
				wave_flag.visible = true

		WaveMgr.start_wave_timer.connect(_on_start_wave_timer)


func _on_start_wave_timer(wave_idx: int) -> void:
	var wave: Wave = WaveMgr.wave_group.wave_list[wave_idx]
	var wave_interval: float = wave.interval

	for sub_wave: SubWave in wave.sub_wave_list:
		for spawn: WaveSpawn in sub_wave.spawn_list:
			var bound_pathway_node: Pathway = PathwayMgr.get_pathway(spawn.pathway_idx)
			var wave_flag: WaveFlag = wave_flag_dict[bound_pathway_node]
			wave_flag._show(wave_interval)


func _get_configuration_warnings() -> PackedStringArray:
	var warn: PackedStringArray = []
	
	if not get_children():
		warn.append("请至少增加一个 WaveFlag 子节点，否则无法显示波次到来时间。")
		
	return warn
