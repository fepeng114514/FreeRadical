@tool
extends EditorInspectorPlugin

func _can_handle(object: Object) -> bool:
	return true


func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	if type == TYPE_INT and hint_string.begins_with("mask_enum"):
		var enum_property: String = hint_string.split(":")[1]
		
		var editor = preload(
			"res://addons/mask_check/mask_check_editor.gd"
		).new(enum_property)
		add_property_editor(name, editor)
		return true
		
	return false
