@abstract
extends Node
class_name ECSSystem
## 系统基类。
##
## 系统用于处理实体和组件的逻辑。


func _enter_tree() -> void:
	ECSSystemManager.register_system(self)


func _exit_tree() -> void:
	ECSSystemManager.unregister_system(self)


@warning_ignore_start("unused_parameter")
## 插入实体时调用，返回 false 的实体将会被移除
func _on_insert(entity: ECSEntity) -> bool: return true


## 移除实体时调用，返回 false 的实体将不会被移除
func _on_remove(entity: ECSEntity) -> bool: return true


## 更新实体时调用
func _on_update(delta: float) -> void: pass
@warning_ignore_restore("unused_parameter")
