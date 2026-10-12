@abstract
extends Node2D
class_name Skill
## 技能节点基类
##
## [Skill] 是所有技能节点的基类，技能主要用于 [SkillComponent] 与 [DodgeComponent] 进行技能释放。


## 技能释放后发出。
signal skill_used
## 技能冷却后发出。
signal start_skill_cooldown


## 时间戳。
var timestamp: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

	DebugManager.draw_state_changed.connect(_on_draw_state_changed)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = NodeConfigManager.get_common_configuration_warnings(self)
	
	return warnings


@warning_ignore_start("unused_parameter")
## 检查技能是否可以释放。
func can_use(entity: Entity, config: SkillNodeConfig, target: Entity = null) -> bool:
	if not config:
		return false
		
	if not TimeManager.has_elapsed(timestamp, config.cooldown):
		return false

	if randf() > config.chance:
		return false

	return true


## 释放技能。
func _use_skill(entity: Entity, target: Entity = null) -> void: pass
@warning_ignore_restore("unused_parameter")


## 释放技能。[br][br]
## -> 是否成功释放技能。
func use_skill(entity: Entity, target: Entity = null) -> void:
	_use_skill(entity, target)
	skill_used.emit()


## 开始技能冷却。
func start_cooldown(config: SkillNodeConfig) -> void:
	var tick_timestamp: float = TimeManager.tick_timestamp
	timestamp = tick_timestamp

	if config and config.share_cooldown_enabled:
		var parent: Node = get_parent()
		for skill_index: int in config.share_cooldown_skill_index_list:
			var skill: Skill = parent.get_child(skill_index)
			if skill:
				skill.timestamp = tick_timestamp
	
	start_skill_cooldown.emit()


## 补偿技能冷却时间。
func compensate_cooldown(config: SkillNodeConfig) -> void:
	timestamp -= config.compensate_cooldown_percent * config.cooldown


func _on_config_changed() -> void:
	queue_redraw()


func _on_draw_state_changed(_draw_type: DebugManager.DrawType) -> void:
	queue_redraw()
