extends Resource
class_name SameProcessResource


enum SameMode {
	## 允许叠加
	MULTIPLE,
	## 重置持续时间
	RESET,
	## 替换相同的光环
	REPLACE,
	## 叠加持续时间
	STACK,
}


@export var same_mode: SameMode = SameMode.REPLACE


func process(e: Entity, samed_entity_list: Array[Entity]) -> bool:
	samed_entity_list.sort_custom(
		func(a1: Entity, a2: Entity) -> bool: 
			return a1.level > a2.level
	)
	var min_level_e: Entity = samed_entity_list[-1]
	var max_level_e: Entity = samed_entity_list[0]
	
	match same_mode:
		SameMode.MULTIPLE:
			return true
		SameMode.REPLACE:
			min_level_e.remove_entity()
			return true
		SameMode.RESET:
			max_level_e.insert_ts -= TimeMgr.tick_ts
			return false
		SameMode.STACK:
			max_level_e.insert_ts -= e.duration
			return false

	return false
