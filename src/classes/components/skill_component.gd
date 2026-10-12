@tool
@icon("res://assets/dpi_textures/at-icons/node2d/bow_and_arrow.svg")
extends Component
class_name SkillComponent
## 技能组件。
##
## [SkillComponent] 可以让实体释放技能，技能以 [Skill] 子节点的形式存在。


@warning_ignore_start("unused_signal")
## 技能释放后发出。
signal skill_used(skill: Skill)
## 技能冷却后发出。
signal start_skill_cooldown(skill: Skill)
@warning_ignore_restore("unused_signal")


@export var config: SkillComponentNodeConfig = null:
	set(v):
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()
		

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = super()

	if not get_children():
		warnings.append("请至少增加一个 Skill 或其类型的子节点，否则实体无法释放技能。")

	return warnings