extends RefCounted
class_name Damage
## 伤害类。


## 伤害类型枚举。
enum Type {
	## 伤害类型: 无。
	NONE = 0,
	## 伤害类型: 物伤。
	PHYSICAL = 1,
	## 伤害类型: 法伤。
	MAGICAL = 1 << 1,
	## 伤害类型: 炮伤。
	EXPLOSION = 1 << 2,
	## 伤害类型: 法炮伤。
	MAGICAL_EXPLOSION = 1 << 3,
	## 伤害类型: 真伤。
	TRUE = 1 << 4,
	## 伤害类型: 毒伤。
	POISON = 1 << 5,
	## 伤害类型：当前血量百分比
	HP_PERCENT = 1 << 38,
	## 伤害类型：最大血量百分比
	HP_MAX_PERCENT = 1 << 39,
	## 伤害类型: 秒杀。
	INSTAKILL = 1 << 40,
}


## 伤害标识枚举。
enum Flag {
	## 伤害标识：无。	
	NONE = 0,
	## 伤害标识：不杀死目标而是留 1 血。
	NOT_KILL = 1,
	## 伤害标识：杀死目标后直接移除。
	KILL_REMOVE = 1 << 1,
	## 伤害标识：无法闪避。
	NO_DODGE = 1 << 2,
	## 伤害标识：无法反伤。
	NO_SPIKED = 1 << 3,
	## 伤害标识: 远程。
	RANGED = 1 << 20,
	## 伤害标识: 近战。
	MELEE = 1 << 21,
}


## 目标实体 ID。
var target_id: int = Constants.UNSET
## 来源实体 ID。
var source_id: int = Constants.UNSET
## 伤害值。
var value: float = 0.0
## 伤害类型。
var damage_type: int = Type.PHYSICAL
## 伤害标识。	
var damage_flags: int = Flag.NONE
## 来源实体名称。
var source_name: StringName = &""
## 是否为区域伤害。
var is_area: bool = false


## 预测伤害值。
static func predict_damage(p_damage_type: int, p_value: float, target: Entity) -> float:
	var health_c: HealthComponent = target.get_node_or_null(Constants.HEALTH_COMPONENT_NODE_PATH)
		
	if p_damage_type & Type.INSTAKILL:
		return health_c.hp
	else:
		var health_c_config: HealthComponentNodeConfig = health_c.config
		var physical_armor: float = clampf(health_c_config.physical_armor, 0, 1)
		var magical_armor: float = clampf(health_c_config.magical_armor, 0, 1)
		var poison_armor: float = clampf(health_c_config.poison_armor, 0, 1)
		var resistance: float = 1 - health_c_config.damage_resistance

		if not p_damage_type & Type.TRUE:
			if p_damage_type & Type.EXPLOSION:
				resistance *= 1 - physical_armor / 2.0
			elif p_damage_type & Type.PHYSICAL:
				resistance *= 1 - physical_armor
				
			if p_damage_type & Type.MAGICAL_EXPLOSION:
				resistance *= 1 - magical_armor / 2.0
			elif p_damage_type & Type.MAGICAL:
				resistance *= 1 - magical_armor
				
			if p_damage_type & Type.POISON:
				resistance *= 1 - poison_armor
				
		var total_damage_factor: float = resistance * (1 + health_c_config.vulnerable)
		var basic_value: float = p_value
		if p_damage_type & Type.HP_MAX_PERCENT:
			basic_value *= health_c_config.hp_max
		elif p_damage_type & Type.HP_PERCENT:
			basic_value *= health_c.hp

		basic_value -= health_c_config.damage_reduction

		var actual_damage: float = roundi(basic_value * total_damage_factor)
		
		return actual_damage