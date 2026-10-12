@tool
extends Component
class_name OffsetComponent
## 偏移量组件。
##
## [OffsetComponent] 可以让实体的判断点的位置偏移指定的距离。


@export var config: OffsetComponentNodeConfig = null:
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
