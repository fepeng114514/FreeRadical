extends Behavior
class_name SpawnerBehavior
## 生成器行为。
##
## SpawnerBehavior 负责处理拥有 [SpawnerComponent] 生成器组件的实体的生成逻辑。


func _on_insert(entity: Entity) -> bool:
	if not entity.get_node_or_null(Constants.CN_SPAWNER):
		return true
		
	entity._spawner.call()
	
	return true