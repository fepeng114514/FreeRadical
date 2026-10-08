@tool
extends NodeConfig
class_name EntityNodeConfig
## 实体节点配置资源。


## 空闲动画组
@export var idle_animation: AnimationGroup = null
## 生成时播放的动画
@export var spawn_animation: AnimationGroup = null
## 生成时播放的音效组。
@export var spawn_sfx: AudioGroup = null
## 击中位置偏移组。
@export var hit_offsets: OffsetGroup = null:
	set(v): 
		Utils.rebind_changed(hit_offsets, v, emit_changed)
		hit_offsets = v
		emit_changed()
## 光环位置偏移组。
@export var aura_offsets: OffsetGroup = null:
	set(v): 
		Utils.rebind_changed(aura_offsets, v, emit_changed)
		aura_offsets = v
		emit_changed()
@export var interact_policy: InteractPolicy = null:
	set(v):
		Utils.rebind_changed(interact_policy, v, emit_changed)
		interact_policy = v
		emit_changed()

var _init_connect_property_signals: Dictionary[String, Callable] = {
	"hit_offsets": emit_changed,
	"aura_offsets": emit_changed,
	"interact_policy": emit_changed,
}


func _init() -> void:
	super()
		
	Utils.connect_property_signals(self, _init_connect_property_signals)
