@tool
extends Control


var pathway_to_wave_flag_map: Dictionary[Pathway, WaveFlag] = {}


func _ready() -> void:
	if Engine.is_editor_hint():
		pass
	else:
		for child: WaveFlag in get_children():
			pathway_to_wave_flag_map[child.bound_pathway_node] = child

		WaveManager.wave_timer_started.connect(_on_wave_timer_started)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	
	if not get_children():
		warnings.append("请至少增加一个 WaveFlag 子节点，否则无法显示波次信息。")
		
	return warnings


func _on_wave_timer_started(wave_index: int) -> void:
	for pathway_index in WaveManager.current_wave_pathway_indexes:
		var bound_pathway_node: Pathway = PathwayManager.get_pathway(pathway_index)
		var wave_flag: WaveFlag = pathway_to_wave_flag_map[bound_pathway_node]
		wave_flag._show(wave_index)
