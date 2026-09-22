@tool
extends NodeConfig
class_name ModifierComponentNodeConfig
## 状态效果组件节点配置资源。


## 是否跟随目标。
@export var track_target: bool = true
## 属性修改器列表。
@export var property_modifier_list: Array[PropertyModifier] = []
## 相同处理资源。
@export var same_process: SameProcessResource = null
## 是否移除被禁止的状态效果。
@export var remove_banned: bool = true

## 影响资源，用于对目标造成伤害或治愈目标。
@export var influence: Influence = null

@export_group("Cycle")
## 是否启用周期影响。
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var cycle_enabled: bool = false
## 周期时间。
@export var cycle_time: float = 1.0
## 最大周期。
@export var max_cycle: int = Constants.UNSET
