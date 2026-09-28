extends Node
## 系统管理器。
##
## 用于管理所有系统。


var systems: Array[System] = []


func register_system(system: System) -> void:
	systems.append(system)


func unregister_system(system: System) -> void:
	systems.erase(system)


## 更新所有系统。
func process_update(delta: float) -> void:
	for system: System in systems:
		system._on_update(delta)


## 处理实体插入。
func process_entity_insert(entity: Entity) -> bool:
	for system: System in systems:
		if not system._on_insert(entity):
			return false

	return true


## 处理实体移除。
func process_entity_remove(entity: Entity) -> bool:	
	for system: System in systems:
		if not system._on_remove(entity):
			return false

	return true
