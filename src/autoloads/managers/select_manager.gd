extends Node
## 选择管理器。
## 
## [SelectManager] 负责管理选择实体与相关操作。


## 选择模式枚举。
enum SelectMode {
	## 选择模式：无
	NONE,
	## 选择模式：集结
	RALLY,
	## 选择模式：兵营集结
	BARRACK_RALLY,
	## 选择模式：错误
	ERROR,
}


@warning_ignore_start("unused_signal")
## 选择实体时发出。
signal entity_selected(entity: Entity)
## 取消选择实体时发出。
signal entity_deselected
@warning_ignore_restore("unused_signal")


## 选择模式。
var select_mode: SelectMode = SelectMode.NONE
## 选择的位置。
var select_position: Vector2 = Vector2.ZERO
## 是否正在选择。
var is_selecting: bool = false
## 选中的实体。
var selected_entity: Entity = null

		
func cleanup() -> void:
	select_mode = SelectMode.NONE
	select_position = Vector2.ZERO
	is_selecting = false
	selected_entity = null
