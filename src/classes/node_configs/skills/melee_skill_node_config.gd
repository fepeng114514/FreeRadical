@tool
extends SkillNodeConfig
class_name MeleeSkillNodeConfig
## 近战技能节点配置资源。
##
## [MeleeSkillNodeConfig] 用于存储 [MeleeSkill] 的可配置数据。


## 影响资源，用于对目标造成伤害或治愈目标。
@export var influence: Influence = null:
	set(v):
		Utils.rebind_changed(influence, v, emit_changed)
		influence = v
		emit_changed()
## 是否启用搜索第一个目标位置，如果为 false 则以释放者的位置为中心造成影响，而非第一个目标的位置。
@export var search_at_target_position_enabled: bool = false

@export_group("Interact Policy")
## 禁止交互的实体标识。
@export var entity_flag_bans: int = 0
## 禁止交互的实体场景路径。
@export_file("*.tscn") var scene_path_bans: PackedStringArray
## 允许交互的实体场景路径。
@export_file("*.tscn") var scene_path_allows: PackedStringArray

var _init_connect_property_signals: Dictionary[String, Callable] = {
	"influence": emit_changed,
	"interact_policy": emit_changed,
}


func _init() -> void:
	super()
		
	Utils.connect_property_signals(self, _init_connect_property_signals)


func _validate_property(property: Dictionary) -> void:
	super(property)

	match property.name:
		"entity_flag_bans":
			property.hint_string = "mask_check(%s)" % InteractPolicyComponent.EntityFlag
