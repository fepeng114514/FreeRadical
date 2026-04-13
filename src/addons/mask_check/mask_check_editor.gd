@tool
extends EditorProperty

var checkboxes: Array[CheckBox] = []
var enumerate


func _init(enum_property: String) -> void:
	enumerate = C[enum_property]
	# 创建折叠控件
	var foldable_container := FoldableContainer.new()
	foldable_container.folded = true
	add_child(foldable_container)

	# 创建一个容器放置复选框
	var content := VBoxContainer.new()
	foldable_container.add_child(content)

	for key: String in enumerate:
		var checkbox := CheckBox.new()
		checkbox.text = key.capitalize()
		checkbox.toggled.connect(_on_checkbox_toggled.bind(key))
		content.add_child(checkbox)
		checkboxes.append(checkbox)


func _update_property() -> void:
	var current_value: int = get_edited_object().get(get_edited_property())
	
	var i: int = 0
	for key: String in enumerate:
		var value: int = enumerate[key]
		checkboxes[i].set_pressed_no_signal(current_value & value)
		i += 1
		
		
func _on_checkbox_toggled(pressed: bool, key: String) -> void:
	var current_value: int = get_edited_object().get(get_edited_property())
	var value: int = enumerate[key]

	if pressed:
		current_value |= value
	else:
		current_value &= ~value

	get_edited_object().set(get_edited_property(), current_value)
	emit_changed(get_edited_property(), current_value)
