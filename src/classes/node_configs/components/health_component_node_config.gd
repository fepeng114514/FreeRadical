@tool
extends NodeConfig
class_name HealthComponentNodeConfig
## 血量组件节点配置资源。
##
## [HealthComponentNodeConfig] 用于存储 [HealthComponent] 的可配置数据。


## 最大血量。
@export var hp_max: float = 100.0

@export_group("Buff")
## 物理护甲。
@export var physical_armor: float = 0.0
## 魔法护甲。
@export var magical_armor: float = 0.0
## 毒抗性。
@export var poison_armor: float = 0.0
## 回血。
@export var regen_hp: float = 0.0
## 回血冷却（秒）。
@export var regen_cooldown: float = Constants.UNSET
## 待机回血。
@export var idle_regen_hp: float = 0.0
## 待机回血冷却（秒）。
@export var idle_regen_cooldown: float = Constants.UNSET
## 伤害抗性，可以百分比减少受到的伤害。
@export var damage_resistance: float = 0.0
## 伤害减免，可以直接减少受到的伤害值。
@export var damage_reduction: float = 0.0
## 反伤，对伤害来源的反伤。
@export var spiked: float = Constants.UNSET
## 免疫的伤害类型。
@export var immuned: int = Damage.Type.NONE

@export_group("Debuff")
## 易伤，可以百分比增加受到的伤害值。
@export var vulnerable: float = 0.0

@export_group("Death")
## 死亡赏金。
@export var death_gold: float = 0.0
## 死亡动画组。
@export var death_animation: AnimationGroup = null
## 死亡音效组。
@export var death_sfx: AudioGroup = null
## 死亡后实体移除延迟（秒）。
@export var death_remove_delay: float = 2.0
