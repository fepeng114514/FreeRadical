@tool
extends EditorInspectorPlugin

var WaveSetEditor: GDScript = preload("res://addons/wave_editor/wave_set_editor.gd")

func _can_handle(object: Object) -> bool:
	# 处理 WaveSet 类型的资源
	return object is WaveSet

func parse_property(object: Object, type: int, path: String, hint: int, hint_text: String, usage: int) -> bool:
	# 处理 waves 属性
	if path == "waves" and object is WaveSet:
		# 添加自定义控件
		add_custom_control(WaveSetEditor.new(object))
		return true  # 告诉编辑器我们已经处理了这个属性
	return false  # 让默认编辑器处理其他属性
