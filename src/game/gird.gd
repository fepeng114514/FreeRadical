extends TileMapLayer
class_name Grid
## 网格类。


func _ready() -> void:
	visible = false
	
	GridManager.register_grid(self)
