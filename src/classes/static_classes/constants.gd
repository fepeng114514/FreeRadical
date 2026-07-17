class_name C
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


## 标识枚举。
enum Flag {
	## 标识: 无。
	NONE = 0,
	## 标识: 敌人。
	ENEMY = 1,
	## 标识: BOSS。
	BOSS = 1 << 1,
	## 标识: 友军。
	FRIENDLY = 1 << 2,
	## 标识: 单位。
	UNIT = ENEMY | FRIENDLY,
	## 标识: 英雄。
	HERO = 1 << 3,
	## 标识: 防御塔。
	TOWER = 1 << 4,
	## 标识: 状态效果。
	MODIFIER = 1 << 5,
	## 标识: 光环。
	AURA = 1 << 6,
	## 标识: 飞行。
	FLYING = 1 << 7,
	
	## 标识: 远程。
	RANGED = 1 << 20,
	## 标识: 近战。
	MELEE = 1 << 21,
}


## 伤害类型枚举。
enum DamageType {
	## 伤害类型: 无。
	NONE = 0,
	## 伤害类型: 物伤。
	PHYSICAL = 1,
	## 伤害类型: 法伤。
	MAGICAL = 1 << 1,
	## 伤害类型: 炮伤。
	EXPLOSION = 1 << 2,
	## 伤害类型: 法炮伤。
	MAGICAL_EXPLOSION = 1 << 3,
	## 伤害类型: 真伤。
	TRUE = 1 << 4,
	## 伤害类型: 毒伤。
	POISON = 1 << 5,
	## 伤害类型：当前血量百分比
	HP_PERCENT = 1 << 38,
	## 伤害类型：最大血量百分比
	HP_MAX_PERCENT = 1 << 39,
	## 伤害类型: 秒杀。
	INSTAKILL = 1 << 40,
	## 伤害类型：所有伤害类型。
	ALL = 1 << 40 - 1,
}


## 伤害标识枚举。
enum DamageFlag {
	## 伤害标识：无。	
	NONE = 0,
	## 伤害标识：不杀死目标而是留 1 血。
	NOT_KILL = 1,
	## 伤害标识：杀死目标后直接移除。
	KILL_REMOVE = 1 << 1,
	## 伤害标识：无法闪避。
	NO_DODGE = 1 << 2,
	## 伤害标识：无法反伤。
	NO_SPIKED = 1 << 3,
	## 伤害标识: 远程。
	RANGED = 1 << 20,
	## 伤害标识: 近战。
	MELEE = 1 << 21,
}


## 状态效果类型枚举。
enum ModType {
	## 状态效果类型: 无。
	NONE = 0,
	## 状态效果类型: 毒。
	POISON = 1,
	## 状态效果类型: 火。
	LAVA = 1 << 1,
	## 状态效果类型: 流血。
	BLEED = 1 << 2,
	## 状态效果类型: 冻结。
	FREEZE = 1 << 3,
	## 状态效果类型: 眩晕。
	STUN = 1 << 4,
}


## 光环类型枚举。
enum AuraType {
	## 光环类型: 无。
	NONE = 0,
	## 光环类型: 正面效果。
	BUFF = 1,
	## 光环类型: 负面效果。
	DEBUFF = 1 << 1,
}


## 搜索标识枚举。
enum SearchFlag {
	## 搜索标识: 无。
	NONE = 0,
	## 搜索标识: 跳过即将死亡的目标。
	SKIP_READY_DEAD = 1,
}


## 实体信息栏类型枚举。
enum InfoBarType {
	## 信息栏类型：无，不显示。
	NONE,
	## 信息栏类型：敌人或友军的信息栏。
	UNIT,
	## 信息栏类型：防御塔的信息栏。
	TOWER,
	## 信息栏类型：文本。
	TEXT,
}


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


#region 组件路径
## 组件路径: 血量。
const CN_HEALTH: NodePath = ^"HealthComponent"
## 组件路径: 导航路径。
const CN_NAV_PATH: NodePath = ^"NavPathComponent"
## 组件路径: 集结点。
const CN_RALLY: NodePath = ^"RallyComponent"
## 组件路径: 防御塔。
const CN_TOWER: NodePath = ^"TowerComponent"
## 组件路径: 状态效果。
const CN_MODIFIER: NodePath = ^"ModifierComponent"
## 组件路径: 光环。
const CN_AURA: NodePath = ^"AuraComponent"
## 组件路径: 近战技能。
const CN_MELEE: NodePath = ^"MeleeComponent"
## 组件路径: 远程攻击。
const CN_SKILL: NodePath = ^"SkillComponent"
## 组件路径: 子弹。
const CN_BULLET: NodePath = ^"BulletComponent"
## 组件路径: 精灵。
const CN_SPRITE: NodePath = ^"SpriteComponent"
## 组件路径: 兵营。
const CN_BARRACK: NodePath = ^"BarrackComponent"
## 组件路径: 生成器。
const CN_SPAWNER: NodePath = ^"SpawnerComponent"
## 组件路径: UI。
const CN_UI: NodePath = ^"UIComponent"
## 组件路径: FX。
const CN_FX: NodePath = ^"FXComponent"
## 组件路径: 闪避。
const CN_DODGE: NodePath = ^"DodgeComponent"
#endregion


#region 组名称
## 组名: 实体。
const GROUP_ENTITY: StringName = &"entity"
## 组名: 敌人。
const GROUP_ENEMY: StringName = &"enemy"
## 组名: 友军。
const GROUP_FRIENDLY: StringName = &"friendly"
## 组名: 单位。
const GROUP_UNIT: StringName = &"unit"
## 组名: 防御塔。
const GROUP_TOWER: StringName = &"tower"
#endregion
