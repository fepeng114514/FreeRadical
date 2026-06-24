extends Node
## 关卡管理器。
##
## 负责管理关卡与相关操作。


## 关卡索引。
var current_level_idx: int = 1


## 进入指定索引的关卡。
func enter_level(idx: int) -> void:
	LoaderMgr.enter_scene(
		"res://game/levels/level_%d.tscn" % idx
	)

	current_level_idx = idx
