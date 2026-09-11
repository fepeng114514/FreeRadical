@tool
extends EditorInspectorPlugin


static var hint_reg_ex: RegEx = RegEx.create_from_string("mask_check\\((\\{[\\S\\s]*\\})\\)")


func _can_handle(object: Object) -> bool:
	return true


func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	if type != TYPE_INT:
		return false
	
	var match_hint: RegExMatch = hint_reg_ex.search(hint_string)
	if not match_hint:
		return false
		
	var enum_dict: Dictionary = str_to_var(match_hint.get_string(1))
	
	var editor_property: MaskCheckEditorProperty = preload("res://addons/mask_check/mask_check_editor_property.tscn").instantiate()
	editor_property.setup(enum_dict, name, object)
	add_property_editor(name, editor_property)
	
	return true
