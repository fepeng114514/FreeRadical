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
## 组件路径: 选择组件。
const CN_SELECT: NodePath = ^"SelectComponent"
## 组件路径: FX。
const CN_FX: NodePath = ^"FXComponent"
## 组件路径: 闪避。
const CN_DODGE: NodePath = ^"DodgeComponent"
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
#endregion
