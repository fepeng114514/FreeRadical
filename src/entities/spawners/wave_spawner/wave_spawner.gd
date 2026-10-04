@tool
extends Entity
class_name WaveSpawnerEntity


## 波次组。
@export var wave_group: WaveGroup = null:
	set(v):
		wave_group = v
		if wave_spawner_component:
			wave_spawner_component.config.wave_group = v
		update_configuration_warnings()

@onready var wave_spawner_component: WaveSpawnerComponent = get_node_or_null(Constants.WAVE_SPAWNER_COMPONENT_NODE_PATH)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = super()
		
	if not wave_group:
		warnings.append("请在 wave_group 中增加一个 WaveGroup 资源，否则无法生成波次。")
		
	return warnings
