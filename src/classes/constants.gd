class_name C
## 常量库


#region 基础常量
## 帧率
const FPS: int = 60
## 未设置数字
const UNSET: int = -1
## PI 二分之一
const HALF_PI: float = PI / 2
## PI 四分之一
const QUARTER_PI: float = PI / 4
#endregion


## 实体标志 (位运算) 枚举
enum Flag {
	# 标识: 无
	NONE = 0,
	# 标识: 敌人
	ENEMY = 1,
	# 标识: BOSS
	BOSS = 1 << 1,
	# 标识: 友军
	FRIENDLY = 1 << 2,
	# 标识: 单位
	UNIT = ENEMY | FRIENDLY,
	# 标识: 英雄
	HERO = 1 << 3,
	# 标识: 防御塔
	TOWER = 1 << 4,
	# 标识: 状态效果
	MODIFIER = 1 << 5,
	# 标识: 光环
	AURA = 1 << 6,
	# 标识: 飞行
	FLYING = 1 << 7,
}


## 伤害类型 (位运算) 枚举
enum DamageType {
	## 伤害类型: 无
	NONE = 0,
	## 伤害类型: 物伤
	PHYSICAL = 1,
	## 伤害类型: 法伤
	MAGICAL = 1 << 1,
	## 伤害类型: 炮伤
	EXPLOSION = 1 << 2,
	## 伤害类型: 法炮伤
	MAGICAL_EXPLOSION = 1 << 3,
	## 伤害类型: 真伤
	TRUE = 1 << 4,
	## 伤害类型: 毒伤
	POISON = 1 << 5,
	## 伤害类型：当前血量百分比
	HP_PERCENT = 1 << 38,
	## 伤害类型：最大血量百分比
	HP_MAX_PERCENT = 1 << 39,
	## 伤害类型: 秒杀
	DISINTEGRATE = 1 << 40,
	## 伤害类型：所有
	ALL = 1 << 40 - 1,
}


## 伤害标识
enum DamageFlag {
	## 伤害标识：无
	NONE = 0,
	## 伤害标识：不杀死目标而是留 1 血
	NOT_KILL = 1,
	## 伤害标识：杀死目标后直接移除
	KILL_REMOVE = 1 << 1,
	## 伤害标识：无法闪避
	NO_DODGE = 1 << 2,
	## 伤害标识：无法反伤
	NO_SPIKED = 1 << 3,
}


## 状态效果类型 (位运算) 枚举
enum ModType {
	## 状态效果类型: 无
	NONE = 0,
	## 状态效果类型: 毒
	POISON = 1,
	## 状态效果类型: 火
	LAVA = 1 << 1,
	## 状态效果类型: 流血
	BLEED = 1 << 2,
	## 状态效果类型: 冻结
	FREEZE = 1 << 3,
	## 状态效果类型: 眩晕
	STUN = 1 << 4,
}


## 光环类型 (位运算) 枚举
enum AuraType {
	## 光环类型: 无
	NONE = 0,
	## 光环类型: 正面效果
	BUFF = 1,
	## 光环类型: 负面效果
	DEBUFF = 1 << 1,
}


## 搜索模式枚举
enum SearchMode {
	## 搜索模式: 实体路程最远
	ENTITY_MAX_PROGRESS,
	## 搜索模式: 实体路程最近
	ENTITY_MIN_PROGRESS,
	## 搜索模式: 实体距离最远
	ENTITY_MAX_DISTANCE,
	## 搜索模式: 实体距离最近
	ENTITY_MIN_DISTANCE,
	## 搜索模式: 实体血量最高
	ENTITY_MAX_HEALTH,
	## 搜索模式: 实体血量最低
	ENTITY_MIN_HEALTH,
	## 搜索模式: 实体近战伤害最高
	ENTITY_MAX_MELEE_DAMAGE,
	## 搜索模式: 实体近战伤害最低
	ENTITY_MIN_MELEE_DAMAGE,
	## 搜索模式: 实体远程伤害最高
	ENTITY_MAX_RANGED_DAMAGE,
	## 搜索模式: 实体远程伤害最低
	ENTITY_MIN_RANGED_DAMAGE,
	## 搜索模式: 实体 ID 最大
	ENTITY_MAX_ID,
	## 搜索模式: 实体 ID 最小
	ENTITY_MIN_ID,
	## 搜索模式: 实体赏金最高
	ENTITY_MAX_GOLD,
	## 搜索模式: 实体赏金最低
	ENTITY_MIN_GOLD,
	## 搜索模式: 实体随机
	ENTITY_RANDOM,

	## 搜索模式: 敌人路程最远
	ENEMY_MAX_PROGRESS,
	## 搜索模式: 敌人路程最近
	ENEMY_MIN_PROGRESS,
	## 搜索模式: 敌人距离最远
	ENEMY_MAX_DISTANCE,
	## 搜索模式: 敌人距离最近
	ENEMY_MIN_DISTANCE,
	## 搜索模式: 敌人血量最高
	ENEMY_MAX_HEALTH,
	## 搜索模式: 敌人血量最低
	ENEMY_MIN_HEALTH,
	## 搜索模式: 敌人近战伤害最高
	ENEMY_MAX_MELEE_DAMAGE,
	## 搜索模式: 敌人近战伤害最低
	ENEMY_MIN_MELEE_DAMAGE,
	## 搜索模式: 敌人远程伤害最高
	ENEMY_MAX_RANGED_DAMAGE,
	## 搜索模式: 敌人远程伤害最低
	ENEMY_MIN_RANGED_DAMAGE,
	## 搜索模式: 敌人 ID 最大
	ENEMY_MAX_ID,
	## 搜索模式: 敌人 ID 最小
	ENEMY_MIN_ID,
	## 搜索模式: 敌人赏金最高
	ENEMY_MAX_GOLD,
	## 搜索模式: 敌人赏金最低
	ENEMY_MIN_GOLD,
	## 搜索模式: 敌人随机
	ENEMY_RANDOM,

	## 搜索模式: 友军路程最远
	FRIENDLY_MAX_PROGRESS,
	## 搜索模式: 友军路程最近
	FRIENDLY_MIN_PROGRESS,
	## 搜索模式: 友军距离最近
	FRIENDLY_MIN_DISTANCE,
	## 搜索模式: 友军距离最远
	FRIENDLY_MAX_DISTANCE,
	## 搜索模式: 友军血量最高
	FRIENDLY_MAX_HEALTH,
	## 搜索模式: 友军血量最低
	FRIENDLY_MIN_HEALTH,
	## 搜索模式: 友军近战伤害最高
	FRIENDLY_MAX_MELEE_DAMAGE,
	## 搜索模式: 友军近战伤害最低
	FRIENDLY_MIN_MELEE_DAMAGE,
	## 搜索模式: 友军远程伤害最高
	FRIENDLY_MAX_RANGED_DAMAGE,
	## 搜索模式: 友军远程伤害最低
	FRIENDLY_MIN_RANGED_DAMAGE,
	## 搜索模式: 友军 ID 最大
	FRIENDLY_MAX_ID,
	## 搜索模式: 友军 ID 最小
	FRIENDLY_MIN_ID,
	## 搜索模式: 友军赏金最高
	FRIENDLY_MAX_GOLD,
	## 搜索模式: 友军赏金最低
	FRIENDLY_MIN_GOLD,
	## 搜索模式: 友军随机
	FRIENDLY_RANDOM,

	## 搜索模式: 单位路程最远
	UNIT_MAX_PROGRESS,
	## 搜索模式: 单位路程最近
	UNIT_MIN_PROGRESS,
	## 搜索模式: 单位距离最近
	UNIT_MIN_DISTANCE,
	## 搜索模式: 单位距离最远
	UNIT_MAX_DISTANCE,
	## 搜索模式: 单位血量最高
	UNIT_MAX_HEALTH,
	## 搜索模式: 单位血量最低
	UNIT_MIN_HEALTH,
	## 搜索模式: 单位近战伤害最高
	UNIT_MAX_MELEE_DAMAGE,
	## 搜索模式: 单位近战伤害最低
	UNIT_MIN_MELEE_DAMAGE,
	## 搜索模式: 单位远程伤害最高
	UNIT_MAX_RANGED_DAMAGE,
	## 搜索模式: 单位远程伤害最低
	UNIT_MIN_RANGED_DAMAGE,
	## 搜索模式: 单位 ID 最大
	UNIT_MAX_ID,
	## 搜索模式: 单位 ID 最小
	UNIT_MIN_ID,
	## 搜索模式: 单位赏金最高
	UNIT_MAX_GOLD,
	## 搜索模式: 单位赏金最低
	UNIT_MIN_GOLD,
	## 搜索模式: 单位随机
	UNIT_RANDOM,
}


## 实体信息栏类型枚举
enum InfoBarType {
	## 信息栏类型：无，不显示
	NONE,
	## 信息栏类型：敌人或友军的信息栏
	UNIT,
	## 信息栏类型：防御塔的信息栏
	TOWER,
	## 信息栏类型：文本
	TEXT,
}


## 方向枚举 
enum Direction {
	## 方向：上
	UP,
	## 方向：下
	DOWN,
	## 方向：左
	LEFT,
	## 方向：右
	RIGHT,
}


#region 组件名称
## 组件名称: 血量
const CN_HEALTH: NodePath = ^"HealthComponent"
## 组件名称: 导航路径
const CN_NAV_PATH: NodePath = ^"NavPathComponent"
## 组件名称: 集结点
const CN_RALLY: NodePath = ^"RallyComponent"
## 组件名称: 防御塔
const CN_TOWER: NodePath = ^"TowerComponent"
## 组件名称: 状态效果
const CN_MODIFIER: NodePath = ^"ModifierComponent"
## 组件名称: 光环
const CN_AURA: NodePath = ^"AuraComponent"
## 组件名称: 近战攻击
const CN_MELEE: NodePath = ^"MeleeComponent"
## 组件名称: 远程攻击
const CN_SKILL: NodePath = ^"SkillComponent"
## 组件名称: 子弹
const CN_BULLET: NodePath = ^"BulletComponent"
## 组件名称: 精灵
const CN_SPRITE: NodePath = ^"SpriteComponent"
## 组件名称: 兵营
const CN_BARRACK: NodePath = ^"BarrackComponent"
## 组件名称: 生成器
const CN_SPAWNER: NodePath = ^"SpawnerComponent"
## 组件名称: UI
const CN_UI: NodePath = ^"UIComponent"
## 组件名称: FX
const CN_FX: NodePath = ^"FXComponent"
#endregion


#region 组名称 (StringName)
## 组名: 实体
const GROUP_ENTITIES: StringName = &"entities"
## 组名: 敌人
const GROUP_ENEMIES: StringName = &"enemies"
## 组名: 友军
const GROUP_FRIENDLYS: StringName = &"friendlys"
## 组名: 单位
const GROUP_UNIT: StringName = &"units"
## 组名: 防御塔
const GROUP_TOWERS: StringName = &"towers"
## 组名: 状态效果
const GROUP_MODIFIERS: StringName = &"modifiers"
## 组名: 光环
const GROUP_AURAS: StringName = &"auras"
## 组名: 子弹
const GROUP_BULLETS: StringName = &"bullets"
#endregion
