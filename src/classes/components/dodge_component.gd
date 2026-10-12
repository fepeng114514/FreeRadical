@tool
extends Component
class_name DodgeComponent
## 闪避组件。
##
## [DodgeComponent] 可以让实体可以闪避技能与反击，反击技能以 [Skill] 子节点的形式存在。
## @deprecated
## @deprecated: 未实现。


@export var config: DodgeComponentNodeConfig = null:
	set(v): 
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()

## 当前准备释放的反击技能索引。
var ready_skill_index: int = Constants.UNSET
## 反击目标 ID。
var target_id: int = Constants.UNSET


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = super()

	if not get_children():
		warnings.append("请至少增加一个 Skill 节点或其类型的节点，否则实体无法反击。")
	else:
		if not config.can_dodge_melee and not config.can_dodge_ranged:
			warnings.append("请至少启用一个闪避能力，否则实体无法闪避任何攻击。")
		else:
			var has_melee_skill: bool = false
			var has_ranged_skill: bool = false
			for child: Node in get_children():
				if child is MeleeSkill:
					has_melee_skill = true
				else:
					has_ranged_skill = true
				break

			if not config.can_dodge_melee and has_melee_skill:
				warnings.append("无法闪避近战技能，但增加了近战技能。")
			elif not config.can_dodge_ranged and has_ranged_skill:
				warnings.append("无法闪避远程攻击，但增加了远程技能。")
		
	return warnings


func select_skill(entity: Entity, damage: Damage, source: Entity) -> bool:
	for skill_index: int in get_child_count():
		var skill: Skill = get_child(skill_index)

		if not skill.can_use(entity, skill.config):
			continue

		if not config.can_dodge_area and damage.is_area:
			continue
		
		var damage_flags: int = damage.damage_flags
		if damage_flags & Damage.Flag.MELEE:
			var melee_c: MeleeComponent = entity.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
			if not melee_c:
				continue

			if melee_c.is_blocker:
				if not melee_c.blocked_id_list:
					continue
			else:
				if not melee_c.blocker_id_list:
					continue
		elif damage_flags & Damage.Flag.RANGED:
			if not config.can_dodge_ranged:
				continue

			if skill is MeleeSkill:
				continue

		ready_skill_index = skill_index
		target_id = source.id
		return true

	return false