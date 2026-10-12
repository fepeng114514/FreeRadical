@abstract
extends Node
class_name System
## 系统基类。
##
## [System] 是所有系统的基类，用于处理实体和组件的逻辑。


func _enter_tree() -> void:
	SystemManager.register_system(self)


func _exit_tree() -> void:
	SystemManager.unregister_system(self)


@warning_ignore_start("unused_parameter")
## 实体准备时调用。
func _on_ready(entity: Entity) -> void: pass


## 实体插入时调用。[br][br]
## -> 是否插入实体。
func _on_insert(entity: Entity) -> bool: return true


## 实体移除时调用。[br][br]
## -> 是否移除实体。
func _on_remove(entity: Entity) -> bool: return true


## 实体首次更新时调用。
func _on_first_update(entity: Entity) -> void: pass


## 实体更新时调用。
func _on_update(delta: float) -> void: pass
@warning_ignore_restore("unused_parameter")
