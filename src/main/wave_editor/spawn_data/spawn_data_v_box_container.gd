extends VBoxContainer
class_name WaveEditorSpawnDataVBoxContainer


@export var spawn_interval: LabeledSpinBox = null
@export var entity: LabeledOptionButton = null
@export var pathway: LabeledSpinBox = null
@export var sub_pathway: LabeledSpinBox = null
@export var count: LabeledSpinBox = null
@export var enable_reversed: CheckButton = null
@export var enable_loop: CheckButton = null

@export_group("Ref")
@export var wave_editor: WaveEditor = null

var spawn: WaveSpawn = null


func _ready() -> void:
	spawn_interval.spin_box.value_changed.connect(_on_spawn_interval_changed)
	entity.option_button.item_selected.connect(_on_entity_changed)
	pathway.spin_box.value_changed.connect(_on_pathway_changed)
	sub_pathway.spin_box.value_changed.connect(_on_sub_pathway_changed)
	count.spin_box.value_changed.connect(_on_count_changed)
	enable_reversed.toggled.connect(_on_enable_reversed_toggled)
	enable_loop.toggled.connect(_on_enable_loop_toggled)


func set_spawn_data(new_spawn: WaveSpawn) -> void:
	spawn = new_spawn

	spawn_interval.value = spawn.spawn_interval

	entity.option_button.select(wave_editor.enemy_index_dict[spawn.entity])
	pathway.value = spawn.pathway_index
	sub_pathway.value = spawn.sub_pathway_index
	count.value = spawn.count
	spawn_interval.value = spawn.spawn_interval
	enable_reversed.button_pressed = spawn.enable_reversed
	enable_loop.button_pressed = spawn.enable_loop


func _on_spawn_interval_changed(value: float) -> void:
	spawn.spawn_interval = value


func _on_entity_changed(index: int) -> void:
	spawn.entity = wave_editor.enemy_scene_dict[index]


func _on_pathway_changed(value: int) -> void:
	spawn.pathway_index = value


func _on_sub_pathway_changed(value: int) -> void:
	spawn.sub_pathway_index = value


func _on_count_changed(value: int) -> void:
	spawn.count = value 


func _on_enable_reversed_toggled(toggled_on: bool) -> void:
	spawn.enable_reversed = toggled_on


func _on_enable_loop_toggled(toggled_on: bool) -> void:
	spawn.enable_loop = toggled_on
