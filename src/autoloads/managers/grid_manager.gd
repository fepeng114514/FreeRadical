extends Node
## 网格管理器
##
## 负责管理网格与相关操作。


## 网格引用。
var grid: TileMapLayer = null


func _load() -> void:
	grid = null
	
