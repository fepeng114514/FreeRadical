@tool
@abstract
extends NodeConfig
class_name SkillNodeConfig
## 技能节点配置资源基类。
##
## [SkillNodeConfig] 是所有技能配置节点的基类，包含了技能的基本配置属性。


## 是否禁用技能。
@export var disabled: bool = false
## 技能类型标识。
@export var skill_types: int = 0
## 技能释放概率。
@export var chance: float = 1.0
## 技能释放延迟（秒），用于等待动画到达特定帧后再释放技能。
@export var delay: float = 0.0
## 动画组。
@export var animation: FacingAnimationSet = null
## 音效组。
@export var sfx: AudioGroup = null

@export_group("Cooldown")
## 技能冷却时间（秒）。
@export var cooldown: float = 1.0
## 技能冷却时间补偿比例，用于意外情况下被中断释放技能时减少重新冷却的时间。
@export var compensate_cooldown_percent: float = 0.0

@export_subgroup("Share Cooldown")
## 是否启用共享冷却，可以使自身多个技能共享冷却。
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var share_cooldown_enabled: bool = false
## 共享冷却的技能索引列表。
@export var share_cooldown_skill_index_list: Array[int] = []


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"skill_types":
			property.hint_string = "mask_check(%s)" % Skill.Type
