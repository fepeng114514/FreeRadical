@tool
extends NodeConfig
class_name InteractPolicyComponentNodeConfig
## 交互策略组件节点配置。
##
## [InteractPolicyComponentNodeConfig] 用于存储 [InteractPolicyComponent] 的可配置数据。


## 实体阵营。
@export var faction: InteractPolicyComponent.Faction = InteractPolicyComponent.Faction.NONE
## 实体类型。
@export var entity_type: InteractPolicyComponent.EntityType = InteractPolicyComponent.EntityType.NONE
## 实体标识。
@export var entity_flags: int = 0

@export_group("Policy")
## 禁止交互的实体标识。
@export var entity_flag_bans: int = 0
## 禁止交互的技能类型。
@export var skill_type_bans: int = 0
## 禁止交互的修改器类型。
@export var modifier_type_bans: int = 0
## 禁止交互的光环类型。
@export var aura_type_bans: int = 0
## 禁止交互的实体场景路径。
@export_file("*.tscn") var scene_path_bans: PackedStringArray
## 允许交互的实体场景路径。
@export_file("*.tscn") var scene_path_allows: PackedStringArray


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"entity_flags":
			property.hint_string = "mask_check(%s)" % InteractPolicyComponent.EntityFlag
		"entity_flag_bans":
			property.hint_string = "mask_check(%s)" % InteractPolicyComponent.EntityFlag
		"skill_type_bans":
			property.hint_string = "mask_check(%s)" % Skill.Type
		"modifier_type_bans":
			property.hint_string = "mask_check(%s)" % ModifierComponent.Type
		"aura_type_bans":
			property.hint_string = "mask_check(%s)" % AuraComponent.Type
