extends System
class_name EntitySystem
## 实体系统。
##
## [EntitySystem] 负责处理实体。


func _on_remove(entity: Entity) -> bool:
	entity.clear_has_mod_list()
	entity.clear_has_aura_list()

	return true