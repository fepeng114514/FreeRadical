extends Node
## 网格管理器
## 
## [GridManager] 负责管理网格与相关操作。


## 网格引用。
var grid: TileMapLayer = null
	

## 清理网格管理器。
func cleanup() -> void:
	grid = null


## 注册网格。
func register_grid(p_grid: TileMapLayer) -> void:
	grid = p_grid