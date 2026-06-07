@abstract
extends Node
class_name System
## 系统基类。
##
## System 是所有系统的基类，组件的逻辑都是通过系统实现的。


#region 回调函数
@warning_ignore_start("unused_parameter")
## 插入实体时调用，返回 false 的实体将会被移除
func _on_insert(e: Entity) -> bool: return true


## 移除实体时调用，返回 false 的实体将不会被移除
func _on_remove(e: Entity) -> bool: return true


## 更新实体时调用
func _on_update(delta: float) -> void: pass
@warning_ignore_restore("unused_parameter")
#endregion
