extends RefCounted
class_name EntityGroup
## 实体组。
##
## [EntityGroup] 用于存储实体。


## 实体组内的实体。
var _entities: Array[Entity] = []


func get_entities() -> Array[Entity]:
	return _entities


func append(entity: Entity) -> void:
	_entities.append(entity)


func clear() -> void:
	_entities.clear()