extends Node


## 在全局位置处创建实体。
func create_entities_at_global_position(
		entity_scenes: PackedStringArray, 
		create_position: Vector2, 
		auto_insert: bool = true 
	) -> Array[ECSEntity]:
	return ECSEntityManager.create_entities(
		entity_scenes, func(entity): entity.set_global_position_with_components(create_position), auto_insert
	)


## 批量创建状态效果实体。
func create_mods(
		target_id: int,
		entity_scenes: PackedStringArray, 
		source_id: int = Constants.UNSET,
		auto_insert: bool = true
	) -> Array[ECSEntity]:
	
	return ECSEntityManager.create_entities(
		entity_scenes, 
		func(entity):
		entity.target_id = target_id
		entity.source_id = source_id
		, 
		auto_insert
	)


## 批量创建光环实体。
func create_auras(
		target_id: int,
		entity_scenes: PackedStringArray, 
		source_id: int = Constants.UNSET,
		auto_insert: bool = true
	) -> Array[ECSEntity]:
	
	return ECSEntityManager.create_entities(
		entity_scenes, 
		func(entity):
		entity.target_id = target_id
		entity.source_id = source_id
		, 
		auto_insert
	)
