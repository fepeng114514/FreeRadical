@tool
extends NodeConfig
class_name ModifierComponentNodeConfig
## 修改器组件节点配置资源。


## 等级。
@export var level: int = 1
## 是否跟随目标。
@export var track_target: bool = true
## 属性修改器列表。
@export var property_modifier_list: Array[PropertyModifier] = []
## 相同修改器叠加策略资源。
@export var same_stack_policy: SameModifierStackPolicy = null
## 是否移除被禁止的修改器。
@export var remove_banned: bool = true

@export_group("Influence")
## 影响资源，用于对目标造成伤害或治愈目标。
@export var influence: Influence = null
## 造成影响间隔时间。
@export var influence_interval: float = 0.0
## 最大影响次数，-1 表示无限次数。
@export var max_influence_count: int = 1
## 影响延迟时间。
@export var influence_delay: float = 0.0
## 影响动画。
@export var influence_animation: AnimationGroup = null