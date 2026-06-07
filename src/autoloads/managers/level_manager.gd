extends Node
## 关卡管理器。
##
## 负责管理关卡与相关操作。


## 关卡索引。
var level_idx: int = 1


## 进入指定索引的关卡。
func enter_level(idx: int) -> void:
	level_idx = idx
	
	AudioMgr._load()
	EntityMgr._load()
	SearchMgr._load()
	PathwayMgr._load()
	GridMgr._load()

	get_tree().change_scene_to_file(
		"res://levels/level_%d.tscn" % idx
	)
