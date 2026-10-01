extends Resource
class_name SameModifierStackPolicy
## 相同修改器叠加策略资源。
##
## SameModifierStackPolicy 用于处理多个相同类型的修改器如何叠加。


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


## 应用相同修改器叠加策略。
func apply(modifier: Entity, samed_entity_list: Array[Entity]) -> bool:
	samed_entity_list.sort_custom(
		func(m1: Entity, m2: Entity) -> bool: 
			var modifier_c1: ModifierComponent = m1.get_node_or_null(Constants.CN_MODIFIER)
			var modifier_c2: ModifierComponent = m2.get_node_or_null(Constants.CN_MODIFIER)
			return modifier_c1.config.level > modifier_c2.config.level
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
			max_level_e.inserted_time_stamp -= modifier.config.duration
			return false

	return false
