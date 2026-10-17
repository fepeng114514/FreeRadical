@abstract
extends Object
class_name Enums
## 枚举库。
##
## [Enums] 存储了一些枚举。


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


## 组件标识枚举。
enum ComponentFlag {
	## 组件标识: 光环。
	AURA,
	## 组件标识: 兵营。
	BARRACK,
	## 组件标识: 建造。
	BUILD,
	## 组件标识: 子弹。
	BULLET,
	## 组件标识: 闪避。
	DODGE,
	## 组件标识: FX。
	FX,
	## 组件标识: 血量。
	HEALTH,
	## 组件标识: 近战技能。
	MELEE,
	## 组件标识: 修改器。
	MODIFIER,
	## 组件标识: 导航路径。
	NAV_PATH,
	## 组件标识: 集结点。
	RALLY,
	## 组件标识: 选择组件。
	SELECT,
	## 组件标识: 远程攻击。
	SKILL,
	## 组件标识: 出售。
	SELL,
	## 组件标识: 生成器。
	SPAWNER,
	## 组件标识: 精灵。
	SPRITE,
	## 组件标识: 动画精灵。
	ANIMATED_SPRITE,
	## 组件标识: 防御塔。
	TOWER,
	## 组件标识: 波次生成器。
	WAVE_SPAWNER,
	## 组件标识: 升级。
	UPGRADE,
	## 组件标识: 记录组件。
	RECORD,
	## 组件标识: 持续时间组件。
	DURATION,
	## 组件标识: 偏移量组件。
	OFFSET,
	## 组件标识：出生组件。
	BIRTH,
	## 组件标识: 交互策略组件。
	INTERACT_POLICY,
}