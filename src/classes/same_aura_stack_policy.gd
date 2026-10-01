extends Resource
class_name SameAuraStackPolicy
## 相同光环叠加策略资源。
##
## SameAuraStackPolicy 用于处理多个相同类型的光环如何叠加。


## 模式枚举。
enum Mode {
	## 模式：允许叠加。
	MULTIPLE,
	## 模式：重置持续时间。
	RESET,
	## 模式：替换。
	REPLACE,
	## 模式：叠加持续时间。
	STACK,
}


## 处理模式。
@export var mode: Mode = Mode.REPLACE


## 应用相同光环叠加策略。
func apply(aura: Entity, samed_entity_list: Array[Entity]) -> bool:
	samed_entity_list.sort_custom(
		func(a1: Entity, a2: Entity) -> bool: 
			var aura_c1: AuraComponent = a1.get_node_or_null(Constants.CN_AURA)
			var aura_c2: AuraComponent = a2.get_node_or_null(Constants.CN_AURA)
			return aura_c1.config.level > aura_c2.config.level
	)
	var min_level_e: Entity = samed_entity_list[-1]
	var max_level_e: Entity = samed_entity_list[0]
	
	match mode:
		Mode.MULTIPLE:
			return true
		Mode.REPLACE:
			EntityManager.queue_remove_entity(min_level_e)
			return true
		Mode.RESET:
			max_level_e.inserted_time_stamp -= TimeManager.tick_time_stamp
			return false
		Mode.STACK:
			max_level_e.inserted_time_stamp -= aura.config.duration
			return false

	return false
