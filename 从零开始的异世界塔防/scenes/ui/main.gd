extends PanelContainer


func _ready() -> void:
	if Global.IS_DEBUG:
		UpdateJsonDatas.new()._run()
