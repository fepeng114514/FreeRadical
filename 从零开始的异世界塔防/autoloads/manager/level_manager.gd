extends Node

"""关卡管理器:
	管理进入关卡与关卡数据
"""


func enter_level(idx: int) -> void:
	GlobalStore.level_idx = idx
	
	EntityDB.load()
	PathDB.load()
	GridDB.load()

	get_tree().change_scene_to_file(
		"res://scenes/levels/level_%d.tscn" % idx
	)
