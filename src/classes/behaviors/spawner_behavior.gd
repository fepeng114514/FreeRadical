extends Behavior
class_name SpawnerBehavior
## 生成器行为。
##
## SpawnerBehavior 负责处理拥有 [SpawnerComponent] 生成器组件的实体的生成逻辑。


func _on_insert(e: Entity) -> bool:
	if not e.get_node_or_null(C.CN_SPAWNER):
		return true
		
	e._spawner.call()
	
	return true