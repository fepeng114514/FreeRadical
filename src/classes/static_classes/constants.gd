@abstract
extends Object
class_name Constants
## 常量库。
##
## [Constants] 存储了一些常量。


## 帧率。
const FPS: int = 60
## 未设置数字。
const UNSET: int = -1
## PI 二分之一。
const HALF_PI: float = PI / 2
## PI 四分之一。
const QUARTER_PI: float = PI / 4
## 64 位整型的一半长度。
const INT64_LEN_HALF: int = 32


#region 节点路径
## 节点路径: 光环。
const AURA_COMPONENT_NODE_PATH: NodePath = ^"AuraComponent"
## 节点路径: 兵营。
const BARRACK_COMPONENT_NODE_PATH: NodePath = ^"BarrackComponent"
## 节点路径: 建造。
const BUILD_COMPONENT_NODE_PATH: NodePath = ^"BuildComponent"
## 节点路径: 子弹。
const BULLET_COMPONENT_NODE_PATH: NodePath = ^"BulletComponent"
## 节点路径: 闪避。
const DODGE_COMPONENT_NODE_PATH: NodePath = ^"DodgeComponent"
## 节点路径: FX。
const FX_COMPONENT_NODE_PATH: NodePath = ^"FXComponent"
## 节点路径: 血量。
const HEALTH_COMPONENT_NODE_PATH: NodePath = ^"HealthComponent"
## 节点路径: 近战技能。
const MELEE_COMPONENT_NODE_PATH: NodePath = ^"MeleeComponent"
## 节点路径: 修改器。
const MODIFIER_COMPONENT_NODE_PATH: NodePath = ^"ModifierComponent"
## 节点路径: 导航路径。
const NAV_PATH_COMPONENT_NODE_PATH: NodePath = ^"NavPathComponent"
## 节点路径: 集结点。
const RALLY_COMPONENT_NODE_PATH: NodePath = ^"RallyComponent"
## 节点路径: 选择组件。
const SELECT_COMPONENT_NODE_PATH: NodePath = ^"SelectComponent"
## 节点路径: 远程攻击。
const SKILL_COMPONENT_NODE_PATH: NodePath = ^"SkillComponent"
## 节点路径: 出售。
const SELL_COMPONENT_NODE_PATH: NodePath = ^"SellComponent"
## 节点路径: 生成器。
const SPAWNER_COMPONENT_NODE_PATH: NodePath = ^"SpawnerComponent"
## 节点路径: 精灵。
const SPRITE_COMPONENT_NODE_PATH: NodePath = ^"SpriteComponent"
## 节点路径: 动画精灵。
const ANIMATED_SPRITE_COMPONENT_NODE_PATH: NodePath = ^"AnimatedSpriteComponent"
## 节点路径: 防御塔。
const TOWER_COMPONENT_NODE_PATH: NodePath = ^"TowerComponent"
## 节点路径: 波次生成器。
const WAVE_SPAWNER_COMPONENT_NODE_PATH: NodePath = ^"WaveSpawnerComponent"
## 节点路径: 升级。
const UPGRADE_COMPONENT_NODE_PATH: NodePath = ^"UpgradeComponent"
## 节点路径: 记录组件。
const RECORD_COMPONENT_NODE_PATH: NodePath = ^"RecordComponent"
## 节点路径: 价格记录。
const PRICE_RECORD_NODE_PATH: NodePath = ^"RecordComponent/PriceRecord"
## 节点路径: 防御塔记录。
const TOWER_RECORD_NODE_PATH: NodePath = ^"RecordComponent/TowerRecord"
## 节点路径: 兵营记录。
const BARRACK_RECORD_NODE_PATH: NodePath = ^"RecordComponent/BarrackRecord"
## 节点路径: 持续时间组件。
const DURATION_COMPONENT_NODE_PATH: NodePath = ^"DurationComponent"
## 节点路径: 偏移量组件。
const OFFSET_COMPONENT_NODE_PATH: NodePath = ^"OffsetComponent"
## 节点路径: 出生组件。
const BIRTH_COMPONENT_NODE_PATH: NodePath = ^"BirthComponent"
## 节点路径: 交互策略组件。
const INTERACT_POLICY_COMPONENT_NODE_PATH: NodePath = ^"InteractPolicyComponent"
#endregion


## 组件名称到组件标识的映射。
const COMPONENT_NAME_TO_FLAG: Dictionary[StringName, Enums.ComponentFlag] = {
	&"AuraComponent": Enums.ComponentFlag.AURA,
	&"BarrackComponent": Enums.ComponentFlag.BARRACK,
	&"BuildComponent": Enums.ComponentFlag.BUILD,
	&"BulletComponent": Enums.ComponentFlag.BULLET,
	&"DodgeComponent": Enums.ComponentFlag.DODGE,
	&"FxComponent": Enums.ComponentFlag.FX,
	&"HealthComponent": Enums.ComponentFlag.HEALTH,
	&"MeleeComponent": Enums.ComponentFlag.MELEE,
	&"ModifierComponent": Enums.ComponentFlag.MODIFIER,
	&"NavPathComponent": Enums.ComponentFlag.NAV_PATH,
	&"RallyComponent": Enums.ComponentFlag.RALLY,
	&"SelectComponent": Enums.ComponentFlag.SELECT,
	&"SkillComponent": Enums.ComponentFlag.SKILL,
	&"SellComponent": Enums.ComponentFlag.SELL,
	&"SpawnerComponent": Enums.ComponentFlag.SPAWNER,
	&"SpriteComponent": Enums.ComponentFlag.SPRITE,
	&"AnimatedSpriteComponent": Enums.ComponentFlag.ANIMATED_SPRITE,
	&"TowerComponent": Enums.ComponentFlag.TOWER,
	&"WaveSpawnerComponent": Enums.ComponentFlag.WAVE_SPAWNER,
	&"UpgradeComponent": Enums.ComponentFlag.UPGRADE,
	&"RecordComponent": Enums.ComponentFlag.RECORD,
	&"DurationComponent": Enums.ComponentFlag.DURATION,
	&"OffsetComponent": Enums.ComponentFlag.OFFSET,
	&"BirthComponent": Enums.ComponentFlag.BIRTH,
	&"InteractPolicyComponent": Enums.ComponentFlag.INTERACT_POLICY,
}
