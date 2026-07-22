@abstract
extends Node2D
class_name Skill
## 技能节点基类
##
## Skill 是所有技能节点的基类，提供了技能的基本属性和功能。


## 是否禁用技能。
@export var disabled: bool = false
## 技能冷却时间。
@export var cooldown: float = 1.0
## 技能冷却时间补偿比例，用于意外情况下被中断释放技能时减少重新冷却的时间。
@export var compensate_cooldown_percent: float = 0.0
## 技能释放概率。
@export var chance: float = 1.0
## 技能释放延迟（秒），用于等待动画到达特定帧后再释放技能。
@export var delay: float = 0.0
## 动画组。
@export var animation: AnimationGroup = null
## 音效组。
@export var sfx: AudioGroup = null

@export_group("Share Cooldown")
## 是否启用共享冷却。
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var share_cooldown_enable: bool = false
## 共享冷却 id，相同 id 的技能会共享冷却。
@export var share_cooldown_id: int = 0
## 共享冷却偏移。
@export var share_cooldown_offset: float = 0.0

@export_group("Group Share Cooldown")
## 是否启用组实体共享冷却。
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var group_share_cooldown_enable: bool = false
## 实体组共享冷却 id，相同 id 的技能会共享冷却。
@export var group_share_cooldown_id: int = 0
## 实体组共享冷却偏移。
@export var group_share_cooldown_offset: float = 0.1

## 时间戳。
var ts: float = 0.0


@warning_ignore_start("unused_parameter")
## 检查技能是否可以释放。
func can_do(e: Entity, target: Entity = null) -> bool:
	if not TimeMgr.has_elapsed(ts, cooldown):
		return false

	if randf() > chance:
		return false

	return true


## 释放技能。
func _do_skill(e: Entity, target: Entity = null) -> void: pass
@warning_ignore_restore("unused_parameter")


## 开始技能冷却。
func start_cooldown(e: Entity) -> void:
	var tick_ts: float = TimeMgr.tick_ts
	ts = tick_ts

	if share_cooldown_enable:
		var skill_c: SkillComponent = e.get_node_or_null(C.CN_SKILL)
		for skill: Skill in skill_c.get_children():
			if skill.share_cooldown_id != share_cooldown_id:
				continue
			
			skill.ts = tick_ts - share_cooldown_offset
	
	if group_share_cooldown_enable:
		for member: Entity in e.get_parent().get_children():
			if member == e:
				continue
			
			var skill_c: SkillComponent = member.get_node_or_null(C.CN_SKILL)
			if not skill_c:
				return
				
			for skill: Skill in skill_c.get_children():
				if skill.group_share_cooldown_id != group_share_cooldown_id:
					continue
				
				skill.ts = tick_ts - group_share_cooldown_offset


## 补偿技能冷却时间。
func compensate_cooldown(_e: Entity) -> void:
	ts -= compensate_cooldown_percent * cooldown
