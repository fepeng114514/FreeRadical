@tool
extends NodeConfig
class_name EntityComponentNodeConfig
## 实体组件节点配置。
##
## 实体组件节点配置用于存储实体的数据。


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
