@abstract
extends Object
class_name Constants
## 常量库。
##
## 存储了一些常量与枚举，用于在代码中进行计算、比较等操作。


#region 基础常量
## 帧率。
const FPS: int = 60
## 未设置数字。
const UNSET: int = -1
## PI 二分之一。
const HALF_PI: float = PI / 2
## PI 四分之一。
const QUARTER_PI: float = PI / 4
#endregion


## 方向枚举。
enum Direction {
	## 方向：无。
	NONE = 0,
	## 方向：上。
	UP = 1,
	## 方向：下。
	DOWN = 1 << 1,
	## 方向：左。
	LEFT = 1 << 2,
	## 方向：右。
	RIGHT = 1 << 3,
	## 方向：左上角。
	LEFT_UP = UP | LEFT,
	## 方向：左下角。
	LEFT_DOWN = DOWN | LEFT,
	## 方向：右上角。
	RIGHT_UP = UP | RIGHT,
	## 方向：右下角。
	RIGHT_DOWN = DOWN | RIGHT,
}


#region 组件名
## 组件名: 光环。
const AURA_COMPONENT_NAME: StringName = &"AuraComponent"
## 组件名: 兵营。
const BARRACK_COMPONENT_NAME: StringName = &"BarrackComponent"
## 组件名: 建造。
const BUILD_COMPONENT_NAME: StringName = &"BuildComponent"
## 组件名: 子弹。
const BULLET_COMPONENT_NAME: StringName = &"BulletComponent"
## 组件名: 闪避。
const DODGE_COMPONENT_NAME: StringName = &"DodgeComponent"
## 组件名: FX。
const FX_COMPONENT_NAME: StringName = &"FXComponent"
## 组件路径: 血量。
const HEALTH_COMPONENT_NAME: StringName = &"HealthComponent"
## 组件名: 近战技能。
const MELEE_COMPONENT_NAME: StringName = &"MeleeComponent"
## 组件名: 修改器。
const MODIFIER_COMPONENT_NAME: StringName = &"ModifierComponent"
## 组件名: 导航路径。
const NAV_PATH_COMPONENT_NAME: StringName = &"NavPathComponent"
## 组件名: 集结点。
const RALLY_COMPONENT_NAME: StringName = &"RallyComponent"
## 组件名: 选择组件。
const SELECT_COMPONENT_NAME: StringName = &"SelectComponent"
## 组件名: 远程攻击。
const SKILL_COMPONENT_NAME: StringName = &"SkillComponent"
## 组件名: 出售。
const SELL_COMPONENT_NAME: StringName = &"SellComponent"
## 组件名: 生成器。
const SPAWNER_COMPONENT_NAME: StringName = &"SpawnerComponent"
## 组件名: 精灵。
const SPRITE_COMPONENT_NAME: StringName = &"SpriteComponent"
## 组件名: 防御塔。
const TOWER_COMPONENT_NAME: StringName = &"TowerComponent"
## 组件名: 波次生成器。
const WAVE_SPAWNER_COMPONENT_NAME: StringName = &"WaveSpawnerComponent"
## 组件名: 升级。
const UPGRADE_COMPONENT_NAME: StringName = &"UpgradeComponent"
## 组件名: 价格记录。
const PRICE_RECORD_NAME: StringName = &"PriceRecord"
## 组件名: 防御塔记录。
const TOWER_RECORD_NAME: StringName = &"TowerRecord"

const ALL_COMPONENT_NAMES: Array[StringName] = [
	AURA_COMPONENT_NAME, 
	BARRACK_COMPONENT_NAME, 
	BUILD_COMPONENT_NAME, 
	BULLET_COMPONENT_NAME, 
	DODGE_COMPONENT_NAME, 
	FX_COMPONENT_NAME, 
	HEALTH_COMPONENT_NAME, 
	MELEE_COMPONENT_NAME, 
	MODIFIER_COMPONENT_NAME, 
	NAV_PATH_COMPONENT_NAME, 
	RALLY_COMPONENT_NAME, 
	SELECT_COMPONENT_NAME, 
	SKILL_COMPONENT_NAME, 
	SELL_COMPONENT_NAME, 
	SPAWNER_COMPONENT_NAME, 
	SPRITE_COMPONENT_NAME, 
	TOWER_COMPONENT_NAME, 
	WAVE_SPAWNER_COMPONENT_NAME, 
	UPGRADE_COMPONENT_NAME, 
	PRICE_RECORD_NAME, 
	TOWER_RECORD_NAME
]

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
## 节点路径: 防御塔。
const TOWER_COMPONENT_NODE_PATH: NodePath = ^"TowerComponent"
## 节点路径: 波次生成器。
const WAVE_SPAWNER_COMPONENT_NODE_PATH: NodePath = ^"WaveSpawnerComponent"
## 节点路径: 升级。
const UPGRADE_COMPONENT_NODE_PATH: NodePath = ^"UpgradeComponent"
## 节点路径: 价格记录。
const PRICE_RECORD_NODE_PATH: NodePath = ^"PriceRecord"
## 节点路径: 防御塔记录。
const TOWER_RECORD_NODE_PATH: NodePath = ^"TowerRecord"
#endregion


#region 组名称
## 组名: 实体。
const GROUP_ENTITIES: StringName = &"entities"
## 组名: 敌人。
const GROUP_ENEMIES: StringName = &"enemies"
## 组名: 友军。
const GROUP_FRIENDLIES: StringName = &"friendlies"
## 组名: 单位。
const GROUP_UNITS: StringName = &"units"
## 组名: 防御塔。
const GROUP_TOWERS: StringName = &"towers"

const ALL_GROUPS: Array[StringName] = [
	GROUP_ENTITIES, 
	GROUP_ENEMIES, 
	GROUP_FRIENDLIES, 
	GROUP_UNITS, 
	GROUP_TOWERS,
]
#endregion
