@tool
extends RangedBase
class_name RangedLoopAttack
## 循环远程攻击节点


## 循环次数
@export var loop_count: int = 1
## 攻击动画
@export var start_animation: AnimationGroup = null
## 循环动画
@export var loop_animation: AnimationGroup = null
## 结束动画
@export var end_animation: AnimationGroup = null
## 攻击音效
@export var start_sfx: AudioGroup = null
## 攻击音效
@export var loop_sfx: AudioGroup = null
## 攻击音效
@export var end_sfx: AudioGroup = null
