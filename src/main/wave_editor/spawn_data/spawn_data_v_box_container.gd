extends VBoxContainer
class_name WaveEditorSpawnDataVBoxContainer


@export var spawn_interval: LabeledSpinBox = null
@export var entity: LabeledOptionButton = null
@export var pathway: LabeledSpinBox = null
@export var sub_pathway: LabeledSpinBox = null
@export var count: LabeledSpinBox = null
@export var reversed: CheckButton = null
@export var loop: CheckButton = null

@export_group("Ref")
@export var wave_editor: WaveEditor = null

var spawn: WaveSpawn = null


func _ready() -> void:
	spawn_interval.spin_box.value_changed.connect(_on_spawn_interval_changed)
	entity.option_button.item_selected.connect(_on_entity_changed)
	pathway.spin_box.value_changed.connect(_on_pathway_changed)
	sub_pathway.spin_box.value_changed.connect(_on_sub_pathway_changed)
	count.spin_box.value_changed.connect(_on_count_changed)
	reversed.toggled.connect(_on_reversed_toggled)
	loop.toggled.connect(_on_loop_toggled)


func set_spawn_data(new_spawn: WaveSpawn) -> void:
	spawn = new_spawn

	spawn_interval.value = spawn.spawn_interval

	entity.option_button.select(wave_editor.enemy_idx_dict[spawn.entity])
	pathway.value = spawn.pathway_idx
	sub_pathway.value = spawn.sub_pathway_idx
	count.value = spawn.count
	spawn_interval.value = spawn.spawn_interval
	reversed.button_pressed = spawn.reversed
	loop.button_pressed = spawn.loop


func _on_spawn_interval_changed(value: float) -> void:
	spawn.spawn_interval = value


func _on_entity_changed(index: int) -> void:
	spawn.entity = wave_editor.enemy_scene_dict[index]


func _on_pathway_changed(value: int) -> void:
	spawn.pathway_idx = value


func _on_sub_pathway_changed(value: int) -> void:
	spawn.sub_pathway_idx = value


func _on_count_changed(value: int) -> void:
	spawn.count = value 


func _on_reversed_toggled(toggled_on: bool) -> void:
	spawn.reversed = toggled_on


func _on_loop_toggled(toggled_on: bool) -> void:
	spawn.loop = toggled_on
