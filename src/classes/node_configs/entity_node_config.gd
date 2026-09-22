@tool
extends NodeConfig
class_name EntityNodeConfig
## 实体节点配置资源。


## 存在时间（秒），实体存在超过 duration 时间后会被移除，默认值为 -1 表示永久存在。
@export var duration: float = Constants.UNSET
## 空闲动画组
@export var idle_animation: AnimationGroup = null
## 生成时播放的动画
@export var spawn_animation: AnimationGroup = null
## 生成时播放的音效组。
@export var spawn_sfx: AudioGroup = null
## 击中位置偏移组。
@export var hit_offsets: OffsetGroup = null:
	set(v): 
		hit_offsets = v
		emit_changed()
## 光环位置偏移组。
@export var aura_offsets: OffsetGroup = null:
	set(v): 
		aura_offsets = v
		emit_changed()
@export var interact_policy: InteractPolicy = null:
	set(v):
		interact_policy = v
		emit_changed()
