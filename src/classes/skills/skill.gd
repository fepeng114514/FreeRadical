@abstract
extends Node2D
class_name Skill
## 技能节点基类
##
## Skill 是所有技能节点的基类，提供了技能的基本属性和功能。


## 技能释放后发出。
signal skill_used
## 技能冷却后发出。
signal start_skill_cooldown


## 是否禁用技能。
@export var disabled: bool = false
## 技能冷却时间（秒）。
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
## 是否启用共享冷却，可以使自身多个技能共享冷却。
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var share_cooldown_enabled: bool = false
## 共享冷却的技能列表。
@export var share_cooldown_skill_list: Array[Skill] = []

## 时间戳。
var time_stamp: float = 0.0


func _ready() -> void:
	DebugManager.draw_state_changed.connect(_on_draw_state_changed)

	process_mode = Node.PROCESS_MODE_DISABLED
	

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = NodeConfigManager.get_common_configuration_warnings(self)
	
	return warnings


@warning_ignore_start("unused_parameter")
## 检查技能是否可以释放。
func can_use(entity: Entity) -> bool:
	if not TimeManager.has_elapsed(time_stamp, cooldown):
		return false

	if randf() > chance:
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
func start_cooldown() -> void:
	var tick_time_stamp: float = TimeManager.tick_time_stamp
	time_stamp = tick_time_stamp

	if share_cooldown_enabled:
		for skill: Skill in share_cooldown_skill_list:
			skill.time_stamp = tick_time_stamp
	
	start_skill_cooldown.emit()


## 补偿技能冷却时间。
func compensate_cooldown() -> void:
	time_stamp -= compensate_cooldown_percent * cooldown


func _on_config_changed() -> void:
	queue_redraw()


func _on_draw_state_changed(_draw_type: DebugManager.DrawType) -> void:
	queue_redraw()