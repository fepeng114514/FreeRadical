@tool
extends NodeConfig
class_name AuraComponentNodeConfig
## 光环组件节点配置资源。
##
## [AuraComponentNodeConfig] 用于存储 [AuraComponent] 的可配置数据。


## 等级。
@export var level: int = 0
## 是否跟随目标。
@export var track_target: bool = true
## 搜索资源，用于搜索目标。
@export var searcher: Searcher = null:
	set(v):
		Utils.rebind_changed(searcher, v, emit_changed)
		searcher = v
		emit_changed()

@export_group("Apply Policy")
## 光环类型。
@export var aura_types: int = 0

@export_subgroup("Entity")
## 禁止交互的实体标识。
@export var entity_flag_bans: int = 0
## 禁止交互的实体场景路径。
@export_file("*.tscn") var scene_path_bans: PackedStringArray
## 允许交互的实体场景路径。
@export_file("*.tscn") var scene_path_allows: PackedStringArray

@export_subgroup("Other Aura")
## 相同光环叠加策略资源。
@export var same_stack_policy: SameAuraStackPolicy = null
## 排斥的光环类型，如果目标上有指定光环类型，将不会应用光环，值为 true 表示移除被排斥的光环。
@export var exclude_aura_types: Dictionary[AuraComponent.Type, bool] = {}
## 排斥的光环场景路径，如果目标上有指定场景的光环，将不会应用光环，值为 true 表示移除指定场景的光环。
@export_file("*.tscn") var exclude_aura_scene_paths: Dictionary[String, bool] = {}
## 必须包含的光环场景路径，如果目标上没有包含在内的光环，将不会应用光环，值为 true 表示移除包含在外的光环。
@export_file("*.tscn") var include_aura_scene_paths: Dictionary[String, bool] = {}

@export_group("Influence")
## 影响资源，用于对目标造成伤害或治愈目标。
@export var influence: Influence = null:
	set(v):
		Utils.rebind_changed(influence, v, emit_changed)
		influence = v
		emit_changed()
## 造成影响间隔时间。
@export var influence_interval: float = 1.0
## 最大影响次数，-1 表示无限次数。
@export var max_influence_count: int = Constants.UNSET
## 影响延迟时间。
@export var influence_delay: float = 0.0
## 影响动画。
@export var influence_animation: AnimationGroup = null

var _init_connect_property_signals: Dictionary[String, Callable] = {
	"searcher": emit_changed,
	"influence": emit_changed,
}


func _init() -> void:
	super()
		
	Utils.connect_property_signals(self, _init_connect_property_signals)


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"aura_types":
			property.hint_string = "mask_check(%s)" % AuraComponent.Type
		"entity_flag_bans":
			property.hint_string = "mask_check(%s)" % InteractPolicyComponent.EntityFlag
