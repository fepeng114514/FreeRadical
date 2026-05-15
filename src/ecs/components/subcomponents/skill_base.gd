extends Node2D
class_name SkillBase
## 技能节点基类
##
## SkillBase 是所有技能节点的基类，提供了技能的基本属性和功能。


## 是否禁用
@export var disabled: bool = false
## 冷却时间
@export var cooldown: float = 1
## 释放概率
@export var chance: float = 1
## 延迟
@export var delay: float = 0
## 动画
@export var animation: AnimationGroup = null
## 音效
@export var sfx: AudioGroup = null

@export_group("Entity Group Cooldown")
## 是否启用实体组冷却
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var group_cooldown_enable: bool = false
## 实体组冷却偏移
@export var group_cooldown_offset: float = 0.1

## 时间戳
var ts: float = 0


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"flags":
			property.hint_string = "mask_enum:Flag"
		"bans":
			property.hint_string = "mask_enum:Flag"
		"damage_type":
			property.hint_string = "mask_enum:DamageType"
		"damage_flags":
			property.hint_string = "mask_enum:DamageFlag"


@warning_ignore_start("unused_parameter")
func _do_skill(e: Entity) -> void: pass
@warning_ignore_restore("unused_parameter")


static func can_attack(skill: SkillBase, target: Entity) -> bool:
	return (
		target 
		and not U.is_mutual_ban(target.flags, skill.bans, skill.flags, target.bans)
		and U.is_allowed_entity(skill, target)
	)
	
	
static func search_target(e: Entity, skill: SkillBase) -> Entity:
	var target: Entity = EntityMgr.get_entity_by_id(e.target_id)
	if not target:
		var targets: Array[Entity] = EntityMgr.search_targets(
			skill.search_mode, 
			e.global_position, 
			skill.max_range, 
			skill.min_range, 
			skill.flags, 
			skill.bans
		)
		if targets:
			target = targets[0]
		
	if not can_attack(skill, target):
		return null
	
	return target


static func search_targets(e: Entity, skill: SkillBase) -> Array[Entity]:
	var targets: Array[Entity] = EntityMgr.search_targets(
		skill.search_mode, 
		e.global_position, 
		skill.max_range, 
		skill.min_range, 
		skill.flags, 
		skill.bans,
		func(t: Entity) -> bool:
			return can_attack(skill, t)
	)
	
	return targets
