@abstract
extends Node2D
class_name Skill
## 技能节点基类
##
## Skill 是所有技能节点的基类，提供了技能的基本属性和功能。


## 技能类型枚举。
enum Type {
	## 技能类型：无。
	NONE,
	## 技能类型：近战。
	MELEE,
	## 技能类型：远程。
	RANGED
}


## 是否禁用技能。
@export var disabled: bool = false
## 技能冷却时间。
@export var cooldown: float = 1
## 技能冷却时间补偿比例，用于意外情况下被中断释放技能时减少重新冷却的时间。
@export var compensate_cooldown_percent: float = 0.0
## 技能释放概率，用于拥有多个技能时选择释放哪个技能的概率。[br][br]
## [b]注意：[/b]如果在只有一个技能时设置的是技能延后释放一帧的概率。
@export var chance: float = 1
## 技能释放延迟（秒），用于等待动画到达特定帧后再释放技能。
@export var delay: float = 0.0
## 动画组。
@export var animation: AnimationGroup = null
## 音效组。
@export var sfx: AudioGroup = null

@export_group("Entity Group Cooldown")
## 是否启用实体组冷却。
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var group_cooldown_enable: bool = false
## 实体组冷却偏移。
@export var group_cooldown_offset: float = 0.1

## 时间戳。
var ts: float = 0.0


@warning_ignore_start("unused_parameter")
## 检查技能是否可以释放。
func check_ready(e: Entity, target: Entity = null) -> bool:
	if not TimeMgr.has_elapsed(ts, cooldown):
		return false

	if randf() > chance:
		return false

	return true


## 释放技能。
func _do_skill(e: Entity, skill_idx: int, target: Entity = null) -> void: pass
@warning_ignore_restore("unused_parameter")


## 开始技能冷却。
func start_cooldown(e: Entity, skill_idx: int) -> void:
	var tick_ts: float = TimeMgr.tick_ts
	ts = tick_ts

	if group_cooldown_enable:
		var parent: Node = e.get_parent()
		if parent is EntityGroup2D:
			for group_member: Entity in parent.get_children():
				if group_member == e:
					continue
				
				var group_member_skill_c: SkillComponent = group_member.get_node_or_null(C.CN_SKILL)
				if not group_member_skill_c:
					continue
					
				var group_member_s: Skill = group_member_skill_c.get_child(skill_idx)
				group_member_s.ts = tick_ts - group_cooldown_offset 
		

## 补偿技能冷却时间。
func compensate_cooldown(e: Entity, skill_idx: int) -> void:
	ts -= compensate_cooldown_percent * cooldown

	if group_cooldown_enable:
		var parent: Node = e.get_parent()
		if parent is EntityGroup2D:
			for group_member: Entity in parent.get_children():
				if group_member == e:
					continue
				
				var group_member_skill_c: SkillComponent = group_member.get_node_or_null(C.CN_SKILL)
				if not group_member_skill_c:
					continue
					
				var group_member_s: Skill = group_member_skill_c.get_child(skill_idx)
				group_member_s.ts -= compensate_cooldown_percent * group_member_s.cooldown
		
