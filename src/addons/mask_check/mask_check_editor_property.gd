@tool
extends EditorProperty
class_name MaskCheckEditorProperty


@export var checkbox_v_box_container: VBoxContainer = null

## 被编辑的属性名。
var _property_name: String = ""
## 被编辑的对象和属性名。
var _edited_object: Object = null
## 复选框数组。
var _checkboxs: Array[CheckBox] = []
## 枚举字典。
var _enum_dict: Dictionary = {}


## 设置要处理的属性和目标对象。
func setup(enum_dict: Dictionary, property_name: String, edited_object: Object) -> void:
	_property_name = property_name
	_edited_object = edited_object
	_enum_dict = enum_dict

	for key: String in _enum_dict:
		var checkbox := CheckBox.new()
		checkbox.text = key.capitalize()
		checkbox.toggled.connect(_on_checkbox_toggled.bind(key))
		checkbox_v_box_container.add_child(checkbox)
		_checkboxs.append(checkbox)


func _update_property() -> void:
	var current_value: int = _edited_object.get(_property_name)
	
	var checkbox_index: int = 0
	for key: String in _enum_dict:
		var value: int = _enum_dict[key]
		_checkboxs[checkbox_index].set_pressed_no_signal(current_value & value)
		checkbox_index += 1
		
		
func _on_checkbox_toggled(pressed: bool, key: String) -> void:
	var current_value: int = _edited_object.get(_property_name)
	var value: int = _enum_dict[key]

	if pressed:
		current_value |= value
	else:
		current_value &= ~value

	_edited_object.set(_property_name, current_value)
