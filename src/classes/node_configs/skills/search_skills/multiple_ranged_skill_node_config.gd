@tool
extends RangedSkillNodeConfig
class_name MultipleRangedSkillNodeConfig
## 多次远程技能节点配置资源。


## 循环次数。
@export var loop_count: int = 1
## 循环动画组。
@export var loop_animation: AnimationGroup = null
## 结束动画组。
@export var end_animation: AnimationGroup = null
## 攻击音效组。
@export var loop_sfx: AudioGroup = null
## 结束音效组。
@export var end_sfx: AudioGroup = null
