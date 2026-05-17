extends Node2D
class_name Skill
## 技能节点基类
##
## Skill 是所有技能节点的基类，提供了技能的基本属性和功能。


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


@warning_ignore_start("unused_parameter")
func _do_skill(e: Entity) -> void: pass
@warning_ignore_restore("unused_parameter")


static func can_attack(skill: Skill, target: Entity) -> bool:
	return (
		target 
		and not U.is_mutual_ban(target.flags, skill.bans, skill.flags, target.bans)
		and U.is_allowed_entity(skill, target)
	)