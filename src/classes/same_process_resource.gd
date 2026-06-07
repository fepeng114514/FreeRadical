extends Resource
class_name SameProcessResource
## 相同处理资源。
##
## SameProcessResource 用于处理多个相同类型的光环或状态效果如何叠加。


## 处理模式枚举。
enum Mode {
	## 允许叠加。
	MULTIPLE,
	## 重置持续时间。
	RESET,
	## 替换相同的光环。
	REPLACE,
	## 堆叠持续时间。
	STACK,
}


## 处理模式。
@export var mode: Mode = Mode.REPLACE


## 处理相同实体。
func process(e: Entity, samed_entity_list: Array[Entity]) -> bool:
	samed_entity_list.sort_custom(
		func(a1: Entity, a2: Entity) -> bool: 
			return a1.level > a2.level
	)
	var min_level_e: Entity = samed_entity_list[-1]
	var max_level_e: Entity = samed_entity_list[0]
	
	match mode:
		Mode.MULTIPLE:
			return true
		Mode.REPLACE:
			min_level_e.remove_entity()
			return true
		Mode.RESET:
			max_level_e.insert_ts -= TimeMgr.tick_ts
			return false
		Mode.STACK:
			max_level_e.insert_ts -= e.duration
			return false

	return false
