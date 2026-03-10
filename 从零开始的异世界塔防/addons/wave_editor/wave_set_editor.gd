@tool
extends VBoxContainer

var wave_set: WaveSet

func _init(set: WaveSet):
	wave_set = set
	setup_ui()

func setup_ui():
	# 添加标题
	var title = HBoxContainer.new()
	var label = Label.new()
	label.text = "波次编辑器"
	label.add_theme_font_size_override("font_size", 16)
	title.add_child(label)
	title.add_spacer(false)
	
	# 添加全局添加按钮
	var add_wave_btn = Button.new()
	add_wave_btn.text = "+ 添加波次"
	add_wave_btn.pressed.connect(_on_add_wave_pressed)
	title.add_child(add_wave_btn)
	
	add_child(title)
	add_child(HSeparator.new())
	
	# 刷新波次列表
	refresh_wave_list()

func refresh_wave_list():
	# 清除现有内容（除了前两个子节点）
	while get_child_count() > 2:
		remove_child(get_child(2))
	
	# 遍历所有波次
	for i in range(wave_set.waves.size()):
		var wave = wave_set.waves[i]
		add_child(create_wave_editor(i, wave))

func create_wave_editor(index: int, wave: Wave) -> Control:
	var container = VBoxContainer.new()
	
	# 波次标题栏
	var header = HBoxContainer.new()
	
	var fold_btn = Button.new()
	fold_btn.text = "▼"
	fold_btn.toggle_mode = true
	fold_btn.button_pressed = true
	fold_btn.pressed.connect(func(): 
		var content = container.get_child(1)
		content.visible = not content.visible
		fold_btn.text = "▼" if content.visible else "▶"
	)
	header.add_child(fold_btn)
	
	# 波次名称编辑
	var name_edit = LineEdit.new()
	name_edit.text = wave.wave_name
	name_edit.custom_minimum_size.x = 150
	name_edit.text_changed.connect(func(new_text): 
		wave.wave_name = new_text
		notify_property_list_changed()
	)
	header.add_child(name_edit)
	
	header.add_spacer(false)
	
	# 波次操作按钮
	var add_batch_btn = Button.new()
	add_batch_btn.text = "+ 批次"
	add_batch_btn.pressed.connect(_on_add_batch_pressed.bind(wave))
	header.add_child(add_batch_btn)
	
	var remove_wave_btn = Button.new()
	remove_wave_btn.text = "删除"
	remove_wave_btn.add_theme_color_override("font_color", Color.RED)
	remove_wave_btn.pressed.connect(_on_remove_wave_pressed.bind(index))
	header.add_child(remove_wave_btn)
	
	container.add_child(header)
	
	# 波次内容（批次列表）
	var content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	
	# 添加批次编辑器
	for j in range(wave.batches.size()):
		content.add_child(create_batch_editor(wave, j))
	
	container.add_child(content)
	
	# 添加分隔线
	var sep = HSeparator.new()
	sep.modulate.a = 0.3
	container.add_child(sep)
	
	return container

func create_batch_editor(wave: Wave, batch_index: int) -> Control:
	var batch = wave.batches[batch_index]
	
	var container = MarginContainer.new()
	container.add_theme_constant_override("margin_left", 20)
	
	var vbox = VBoxContainer.new()
	
	# 批次标题
	var header = HBoxContainer.new()
	
	var batch_name_edit = LineEdit.new()
	batch_name_edit.text = batch.batch_name
	batch_name_edit.custom_minimum_size.x = 120
	batch_name_edit.text_changed.connect(func(new_text): 
		batch.batch_name = new_text
		notify_property_list_changed()
	)
	header.add_child(batch_name_edit)
	
	header.add_spacer(false)
	
	# 批次操作按钮
	var add_spawn_btn = Button.new()
	add_spawn_btn.text = "+ 敌人生成"
	add_spawn_btn.pressed.connect(_on_add_spawn_pressed.bind(batch))
	header.add_child(add_spawn_btn)
	
	var remove_batch_btn = Button.new()
	remove_batch_btn.text = "删除批次"
	remove_batch_btn.add_theme_color_override("font_color", Color.ORANGE_RED)
	remove_batch_btn.pressed.connect(_on_remove_batch_pressed.bind(wave, batch_index))
	header.add_child(remove_batch_btn)
	
	vbox.add_child(header)
	
	# 敌人生成列表
	for k in range(batch.spawns.size()):
		vbox.add_child(create_spawn_editor(batch, k))
	
	container.add_child(vbox)
	return container

func create_spawn_editor(batch: WaveSpawnBatch, spawn_index: int) -> Control:
	var spawn = batch.spawns[spawn_index]
	
	var container = MarginContainer.new()
	container.add_theme_constant_override("margin_left", 40)
	
	var hbox = HBoxContainer.new()
	
	# 敌人UID
	var uid_edit = LineEdit.new()
	uid_edit.placeholder_text = "敌人UID"
	uid_edit.text = spawn.enemy_uid
	uid_edit.custom_minimum_size.x = 150
	uid_edit.text_changed.connect(func(new_text): 
		spawn.enemy_uid = new_text
		notify_property_list_changed()
	)
	hbox.add_child(uid_edit)
	
	# 数量
	var count_spin = SpinBox.new()
	count_spin.min_value = 1
	count_spin.max_value = 999
	count_spin.value = spawn.count
	count_spin.custom_minimum_size.x = 70
	count_spin.value_changed.connect(func(new_val): 
		spawn.count = new_val
		notify_property_list_changed()
	)
	hbox.add_child(count_spin)
	
	# 延迟
	var delay_spin = SpinBox.new()
	delay_spin.min_value = 0
	delay_spin.max_value = 60
	delay_spin.step = 0.1
	delay_spin.value = spawn.delay
	delay_spin.custom_minimum_size.x = 80
	delay_spin.prefix = "延迟:"
	delay_spin.suffix = "秒"
	delay_spin.value_changed.connect(func(new_val): 
		spawn.delay = new_val
		notify_property_list_changed()
	)
	hbox.add_child(delay_spin)
	
	# 删除按钮
	var remove_btn = Button.new()
	remove_btn.text = "X"
	remove_btn.add_theme_color_override("font_color", Color.RED)
	remove_btn.custom_minimum_size.x = 30
	remove_btn.pressed.connect(_on_remove_spawn_pressed.bind(batch, spawn_index))
	hbox.add_child(remove_btn)
	
	container.add_child(hbox)
	return container

# 按钮回调函数
func _on_add_wave_pressed():
	var new_wave = Wave.new()
	new_wave.wave_name = "波次 " + str(wave_set.waves.size() + 1)
	wave_set.waves.append(new_wave)
	notify_property_list_changed()
	refresh_wave_list()

func _on_add_batch_pressed(wave: Wave):
	var new_batch = WaveSpawnBatch.new()
	new_batch.batch_name = "批次 " + str(wave.batches.size() + 1)
	wave.batches.append(new_batch)
	notify_property_list_changed()
	refresh_wave_list()

func _on_add_spawn_pressed(batch: WaveSpawnBatch):
	var new_spawn = WaveSpawn.new()
	batch.spawns.append(new_spawn)
	notify_property_list_changed()
	refresh_wave_list()

func _on_remove_wave_pressed(index: int):
	wave_set.waves.remove_at(index)
	notify_property_list_changed()
	refresh_wave_list()

func _on_remove_batch_pressed(wave: Wave, index: int):
	wave.batches.remove_at(index)
	notify_property_list_changed()
	refresh_wave_list()

func _on_remove_spawn_pressed(batch: WaveSpawnBatch, index: int):
	batch.spawns.remove_at(index)
	notify_property_list_changed()
	refresh_wave_list()
