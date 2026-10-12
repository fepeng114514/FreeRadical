@abstract
extends Node
class_name Behavior
## 行为基类。
##
## [Behavior] 是所有行为的基类，定义了行为的基本回调函数。


#region 回调函数
@warning_ignore_start("unused_parameter")
## 实体准备时调用。
func _on_ready(entity: Entity) -> void: pass


## 插入实体时调用。[br][br]
## -> 是否插入实体。
func _on_insert(entity: Entity) -> bool: return true


## 移除实体时调用。[br][br]
## -> 是否移除实体。
func _on_remove(entity: Entity) -> bool: return true


## 实体首次更新时调用。
func _on_first_update(entity: Entity) -> void: pass


## 更新实体时调用。[br][br]
## -> 是否阻断后续行为。
func _on_update(entity: Entity) -> bool: return false


## 当行为树中断，且该行为被跳过时调用。
func _on_skip(entity: Entity) -> void: pass
@warning_ignore_restore("unused_parameter")
#endregion
