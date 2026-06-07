@tool
extends Component
class_name DodgeComponent
## 闪避组件。
##
## DodgeComponent 可以使实体拥有闪避与反击的能力，反击技能以 [Skill] 子节点的形式存在。
## @deprecated
## @deprecated: 未实现。


## 是否可以闪避远程攻击。
@export var can_dodge_ranged: bool = true
## 是否可以闪避近战技能。
@export var can_dodge_melee: bool = true
## 是否可以闪避区域攻击。
@export var can_dodge_area: bool = false

## 当前准备释放的反击技能索引。
var skill_idx: int = C.UNSET
var target_id: int = C.UNSET


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []

	if not get_children():
		warnings.append("请至少增加一个 Skill 节点或其类型的节点，否则实体无法反击。")
	else:
		if not can_dodge_melee and not can_dodge_ranged:
			warnings.append("请至少启用一个闪避能力，否则实体无法闪避任何攻击。")
		else:
			var has_melee_skill: bool = false
			var has_ranged_skill: bool = false
			for child: Node in get_children():
				if child is SkillMelee:
					has_melee_skill = true
				else:
					has_ranged_skill = true
				break

			if not can_dodge_melee and has_melee_skill:
				warnings.append("无法闪避近战技能，但增加了近战技能。")
			elif not can_dodge_ranged and has_ranged_skill:
				warnings.append("无法闪避远程攻击，但增加了远程技能。")
		
	return warnings


func select_skill(e: Entity, d: Damage, source: Entity) -> bool:
	for i: int in get_child_count():
		var skill: Skill = get_child(i)

		if not skill.check_ready(e):
			continue

		if not can_dodge_area and d.is_area:
			continue
		
		match d.source_skill_type:
			Skill.Type.MELEE:
				if skill is SkillMelee:
					continue

				var melee_c: MeleeComponent = e.get_node_or_null(C.CN_MELEE)
				if not melee_c:
					continue

				if melee_c.is_blocker:
					if not melee_c.blocked_id_list:
						continue
				else:
					if not melee_c.blocker_id_list:
						continue
			Skill.Type.RANGED:
				if not can_dodge_ranged:
					continue

				if skill is SkillMelee:
					continue

		skill_idx = i
		target_id = source.id
		return true

	return false
