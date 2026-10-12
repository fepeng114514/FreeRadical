@tool
@icon("res://assets/dpi_textures/at-icons/node2d/bullet.svg")
extends Component
class_name BulletComponent
## 子弹组件。
##
## [BulletComponent] 可以让实体按照飞行轨迹飞行，命中目标后造成影响。


@export var config: BulletComponentNodeConfig = null:
	set(v): 
		Utils.rebind_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()


## 目标实体 ID。
var target_id: int = Constants.UNSET
## 起始位置。
var from := Vector2.ZERO
## 目标位置。
var to := Vector2.ZERO
## 时间戳（秒）。
var timestamp: float = 0.0
## 飞行速度（向量）。
var velocity := Vector2.ZERO
## 预判目标全局位置。
var predicted_target_global_position := Vector2.ZERO
## 伤害过的实体 ID 列表。
var damaged_entity_ids := PackedInt32Array()


func _draw() -> void:
	if not config:
		return
		
	if DebugManager.draw_range_enabled:
		if config.influence:
			config.influence.draw_influence_range(self, position)
