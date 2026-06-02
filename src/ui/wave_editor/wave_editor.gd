extends Control
class_name WaveEditor


@export_group("Ref")
@export var wave_track_editor: TrackEditor = null
@export var sub_wave_track_editor: TrackEditor = null
@export var spawn_track_editor: TrackEditor = null
@export var entity_option_button_label: OptionButtonLabel = null

var capitalized_entity_name_dict: Dictionary[String, String] = {}
var wave_list: Array[Wave] = []
var selected_wave: Wave = null


func _ready() -> void:
	var entity_scene_dict: Dictionary[String, PackedScene] = EntityMgr.load_entity_scene()
	for scene_name: String in entity_scene_dict:
		if not scene_name.begins_with("enemy_"):
			continue
		
		var key: String = scene_name.replace("enemy_", "").capitalize()

		capitalized_entity_name_dict[key] = scene_name
		entity_option_button_label.option_button.add_item(key)

	# sub_wave_track_editor.item_select.connect(_on_sub_wave_track_editor_item_select)
# 	sub_wave_track_editor.item_deselect.connect(_on_sub_wave_track_editor_item_deselect)


# func _on_sub_wave_track_editor_item_select(item: TrackEditorTrackItem) -> void:
# 	selected_wave = item


func _on_sub_wave_track_editor_item_deselect() -> void:
	pass
	
