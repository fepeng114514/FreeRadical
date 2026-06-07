extends Node
## 画布管理器。
## 
## 负责管理画布与相关操作。


## 将世界坐标转换为屏幕坐标。
func world_to_screen(world_pos: Vector2) -> Vector2:
	var canvas_transform = get_viewport().canvas_transform
	return canvas_transform * world_pos


## 将屏幕坐标转换为世界坐标。
func screen_to_world(screen_pos: Vector2) -> Vector2:
	var canvas_transform = get_viewport().canvas_transform
	return canvas_transform.affine_inverse() * screen_pos
