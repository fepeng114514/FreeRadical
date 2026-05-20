extends Node2D
class_name Skill
## 技能节点基类
##
## Skill 是所有技能节点的基类，提供了技能的基本属性和功能。


## 是否禁用
@export var disabled: bool = false
## 冷却时间
@export var cooldown: float = 1
## 冷却时间补偿比例
@export var compensate_cooldown_percent: float = 0
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


@warning_ignore_start("unused_parameter")
func _do_skill(e: Entity, skill_idx: int) -> void: pass
@warning_ignore_restore("unused_parameter")


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
		
