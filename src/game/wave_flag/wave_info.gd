extends PanelContainer


@export_group("Ref")
@export var wave_flag: WaveFlag = null
@export var spawn_list: VBoxContainer = null
@export var spawn_list_item_scene: PackedScene = null

var original_position := Vector2.ZERO


func _ready() -> void:
	wave_flag.mouse_entered.connect(_on_mouse_entered)
	wave_flag.mouse_exited.connect(_on_mouse_exited)
	
	visible = false
	original_position = position


func _on_mouse_entered() -> void:
	var current_wave: Wave = WaveMgr.get_current_wave()
	for sub_wave: SubWave in current_wave.sub_wave_list:
		for spawn: WaveSpawn in sub_wave.spawn_list:
			var item: SpawnListItem = spawn_list_item_scene.instantiate()
			item.spawn_entity_text = spawn.entity.resource_path.get_file().get_basename().to_upper()
			item.spawn_count_text = "x%d" % spawn.count
			spawn_list.add_child(item)

	var viewport_rect: Rect2 = get_viewport().get_visible_rect()
	viewport_rect.size = CanvasMgr.screen_to_world(viewport_rect.size)
	
	# 计算位置，确保在可见范围内
	for i: int in 2:
		position = original_position
		var control_rect: Rect2 = get_global_rect()
		var intersection: Rect2 = control_rect.intersection(viewport_rect)
		if intersection.is_equal_approx(control_rect):
			break

		match i:
			0:
				position.y -= wave_flag.size.y + size.y
			1:
				position.x -= wave_flag.size.x + size.x

	visible = true


func _on_mouse_exited() -> void:
	visible = false

	for child: SpawnListItem in spawn_list.get_children():
		child.queue_free()
	
