@tool
extends Component
class_name EntityComponent
## 实体组件。
##
## EntityComponent 用于存储实体的数据。


@export var config: EntityComponentNodeConfig = null:
	set(v): 
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()


func _draw() -> void:
	if DebugManager.draw_offset_enabled:
		if config:
			if config.hit_offsets:
				config.hit_offsets.draw_offset_group(self)
			if config.aura_offsets:
				config.aura_offsets.draw_offset_group(self)
