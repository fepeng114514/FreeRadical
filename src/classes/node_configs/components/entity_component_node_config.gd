@tool
extends NodeConfig
class_name EntityComponentNodeConfig
## 实体组件节点配置。
##
## [EntityComponentNodeConfig] 用于存储 [EntityComponent] 的可配置数据。


@export var interact_policy: InteractPolicy = null:
	set(v):
		Utils.rebind_changed(interact_policy, v, emit_changed)
		interact_policy = v
		emit_changed()

var _init_connect_property_signals: Dictionary[String, Callable] = {
	"interact_policy": emit_changed,
}


func _init() -> void:
	super()
		
	Utils.connect_property_signals(self, _init_connect_property_signals)
