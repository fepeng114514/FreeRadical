@abstract
extends Node
class_name Behavior
## 行为基类。
##
## Behavior 定义了行为的基本回调函数，如插入、移除、更新等。子类需要实现这些回调函数，以定义具体的行为逻辑。


#region 回调函数
@warning_ignore_start("unused_parameter")
## 插入实体时调用。[br][br]
## -> 是否不移除实体。返回 [code]false[/code] 的实体将会被移除。
func _on_insert(e: Entity) -> bool: return true


## 移除实体时调用。[br][br]
## -> 是否移除实体。
func _on_remove(e: Entity) -> bool: return true


## 更新实体时调用。[br][br]
## -> 是否阻断后续行为。
func _on_update(e: Entity) -> bool: return false


## 当行为树中断，且该行为被跳过时调用。
func _on_skip(e: Entity) -> void: pass
@warning_ignore_restore("unused_parameter")
#endregion
