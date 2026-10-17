@tool
extends NodeConfig
class_name ModifierComponentNodeConfig
## 修改器组件节点配置资源。
##
## [ModifierComponentNodeConfig] 用于存储 [ModifierComponent] 的可配置数据。


## 等级。
@export var level: int = 1
## 是否跟随目标。
@export var track_target: bool = true
## 属性修改器列表。
@export var property_modifiers: Array[PropertyModifier] = []

@export_group("Apply Policy")
## 修改器类型。
@export var modifier_types: int = 0

@export_subgroup("Entity")
## 禁止交互的实体标识。
@export var entity_flag_bans: int = 0
## 禁止交互的实体场景路径。
@export_file("*.tscn") var scene_path_bans: PackedStringArray
## 允许交互的实体场景路径。
@export_file("*.tscn") var scene_path_allows: PackedStringArray

@export_subgroup("Other Modifier")
## 相同修改器叠加策略资源。
@export var same_stack_policy: SameModifierStackPolicy = null
## 排斥的修改器类型，如果目标上有指定修改器类型，将不会应用修改器，值为 true 表示移除被排斥的修改器。
@export var exclude_modifier_types: Dictionary[ModifierComponent.Type, bool] = {}
## 排斥的修改器场景路径，如果目标上有指定场景的修改器，将不会应用修改器，值为 true 表示移除指定场景的修改器。
@export_file("*.tscn") var exclude_modifier_scene_paths: Dictionary[String, bool] = {}
## 必须包含的修改器场景路径，如果目标上没有包含在内的修改器，将不会应用修改器，值为 true 表示移除包含在外的修改器。
@export_file("*.tscn") var include_modifier_scene_paths: Dictionary[String, bool] = {}

@export_group("Influence")
## 影响资源，用于对目标造成伤害或治愈目标。
@export var influence: Influence = null:
	set(v):
		Utils.rebind_changed(influence, v, emit_changed)
		influence = v
		emit_changed()
## 造成影响间隔时间。
@export var influence_interval: float = 0.0
## 最大影响次数，-1 表示无限次数。
@export var max_influence_count: int = 1
## 影响延迟时间。
@export var influence_delay: float = 0.0
## 影响动画。
@export var influence_animation: AnimationGroup = null

var _init_connect_property_signals: Dictionary[String, Callable] = {
	"influence": emit_changed,
}


func _init() -> void:
	super()
		
	Utils.connect_property_signals(self, _init_connect_property_signals)


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"modifier_types":
			property.hint_string = "mask_check(%s)" % ModifierComponent.Type
		"entity_flag_bans":
			property.hint_string = "mask_check(%s)" % InteractPolicyComponent.EntityFlag
