extends Node
## 系统管理器。
## 
## [SystemManager] 用于管理所有系统。


## 所有已注册系统。
var _systems: Array[System] = []


func _physics_process(delta: float) -> void:
	process_entity_first_update()
	process_entity_update(delta)


func cleanup() -> void:
	_systems.clear()


## 注册系统。
func register_system(system: System) -> void:
	_systems.append(system)


## 处理实体准备。
func process_entity_ready(entity: Entity) -> void:	
	for system: System in _systems:
		system._on_ready(entity)


## 处理实体插入。
func process_entity_insert(entity: Entity) -> bool:
	for system: System in _systems:
		if not system._on_insert(entity):
			return false

	return true


## 处理实体移除。
func process_entity_remove(entity: Entity) -> bool:	
	for system: System in _systems:
		if not system._on_remove(entity):
			return false

	return true


## 处理实体首次更新。
func process_entity_first_update() -> void:
	for entity: Entity in EntityManager.get_valid_entities():
		if not entity.meta_state & Entity.MetaState.FIRST_UPDATE:
			continue

		entity.meta_state &= ~Entity.MetaState.FIRST_UPDATE
		
		for system: System in _systems:
			system._on_first_update(entity)


## 处理实体更新。
func process_entity_update(delta: float) -> void:
	for system: System in _systems:
		system._on_update(delta)
