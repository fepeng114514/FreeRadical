class_name Damage
## 伤害类。


## 目标实体 ID。
var target_id: int = C.UNSET
## 来源实体 ID。
var source_id: int = C.UNSET
## 伤害值。
var value: float = 0.0
## 伤害类型。
var damage_type: int = C.DamageType.PHYSICAL
## 伤害因子。
var damage_factor: float = 1
## 伤害标识。	
var damage_flags: int = C.DamageFlag.NONE
## 来源实体名称。
var source_name: StringName = &""
## 来源实体技能名称。
var source_skill_type: Skill.Type = Skill.Type.NONE
## 是否为区域伤害。
var is_area: bool = false


## 插入伤害。
func insert_damage() -> void:
	SystemMgr.damage_queue.append(self)


## 预测伤害。
func predict_damage(target: Entity) -> float:
	var health_c: HealthComponent = target.get_node_or_null(C.CN_HEALTH)
		
	if damage_type & C.DamageType.INSTAKILL:
		return health_c.hp
	else:
		var physical_armor: float = clampf(health_c.physical_armor, 0, 1)
		var magical_armor: float = clampf(health_c.magical_armor, 0, 1)
		var poison_armor: float = clampf(health_c.poison_armor, 0, 1)
		
		var resistance: float = 1 - health_c.damage_resistance

		if damage_type & C.DamageType.TRUE:
			pass
		else:
			if damage_type & C.DamageType.EXPLOSION:
				resistance *= 1 - physical_armor / 2.0
			elif damage_type & C.DamageType.PHYSICAL:
				resistance *= 1 - physical_armor
				
			if damage_type & C.DamageType.MAGICAL_EXPLOSION:
				resistance *= 1 - magical_armor / 2.0
			elif damage_type & C.DamageType.MAGICAL:
				resistance *= 1 - magical_armor
				
			if damage_type & C.DamageType.POISON:
				resistance *= 1 - poison_armor
			
		var total_damage_factor: float = damage_factor * resistance * (1 + health_c.vulnerable)
		var basic_value: float = value
		if damage_type & C.DamageType.HP_MAX_PERCENT:
			basic_value *= health_c.hp_max
		elif damage_type & C.DamageType.HP_PERCENT:
			basic_value *= health_c.hp

		basic_value -= health_c.damage_reduction

		var actual_damage: float = roundi(basic_value * total_damage_factor)
		
		return actual_damage
